import { graphDBDriver } from "..";

// Get list of parks liked or reviewed highly by the user's friends and friends-of-friends, ordered by most liked/reviewed first
export const getPopularWithCommunity = async (
  username: string,
): Promise<{ publicId: string }[]> => {
  const driver = await graphDBDriver();
  const session = driver.session({ database: process.env.NEO4J_DATABASE });

  try {
    console.log(`Getting parks liked by users in the community of ${username}`);
    const result = await session.run(
      `
      MATCH (u:User {username: $username})-[:FRIEND*1..2]-(friend:User)
      WHERE friend.username <> $username // Exclude the user themselves
      MATCH (friend)-[:LIKES|RATED_HIGHLY]->(p:Park)
      WITH p, COUNT(DISTINCT friend) AS interactionCount
      RETURN p.publicId AS publicId, interactionCount
      ORDER BY interactionCount DESC
      LIMIT 10
    `,
      { username },
    );

    return result.records.map((record: { get: (arg0: string) => any }) => ({
      publicId: record.get("publicId"),
    }));
  } finally {
    console.log("Got popular with community recommendations, closing graph DB session");
    await session.close();
  }
};

// Use node similarity for link prediction
// Node similarity seems to be more modern that Adamic Adar and jaccard
// Had issues with those 2, also performance with those is bad (no streams)
export const getForYouRecommendations = async (
  username: string,
): Promise<{ publicId: string }[]> => {
  const driver = await graphDBDriver();
  const session = driver.session({ database: process.env.NEO4J_DATABASE });

  // Create projection for link prediction algorithm
  // Projection is a virtual graph to speed up the algorithm
  // Pretend links are undirected for better recommendations (friends are bidirectional anyways)
  try {
    console.log(`Creating graph projection for node similarity recommendations for ${username}`);

    const existsResult = await session.run(`
      CALL gds.graph.exists('userParkGraph') YIELD exists
      RETURN exists
    `);
    const exists = existsResult.records[0].get("exists");

    // Drop projection so new data can be included
    if (exists) {
      await session.run(`CALL gds.graph.drop('userParkGraph') YIELD graphName`);
    }

    // Create projection for node similarity algorithm
    await session.run(`
    CALL gds.graph.project(
        'userParkGraph',
        ['User', 'Park'],
        {
          FRIEND: {
              type: 'FRIEND',
              orientation: 'UNDIRECTED'
          },
          LIKES: {
              type: 'LIKES',
              orientation: 'UNDIRECTED'
          },
          RATED_HIGHLY: {
              type: 'RATED_HIGHLY',
              orientation: 'UNDIRECTED'
          },
          VISITED: {
              type: 'VISITED',
              orientation: 'UNDIRECTED'
          }
        }
    )
    `);

    console.log(
      `Getting "For you" park recommendations for ${username} using node similarity algorithm`,
    );
    const result = await session.run(
      `
    MATCH (u:User {username:$username})

    // Stream for better performance and to handle larger graphs
    // See: https://neo4j.com/docs/graph-data-science/current/algorithms/node-similarity/#algorithms-node-similarity-examples-stream
    CALL gds.nodeSimilarity.stream('userParkGraph', {
      topK: 50
    })
    YIELD node1, node2, similarity

    // Convert node ids back to real nodes
    WITH u, gds.util.asNode(node1) AS sourceUser, gds.util.asNode(node2) AS similarUser, similarity

    // Exclude the user themselves (since they are 100% similar to themselves)
    WHERE sourceUser:User AND similarUser:User 
    AND similarUser.username <> $username

    // Find parks similar users like or rated highly
    MATCH (similarUser)-[:LIKES|RATED_HIGHLY]->(p:Park)
    WHERE NOT (u)-[:LIKES|RATED_HIGHLY]->(p) // Exclude parks the user already likes or rated highly

    // Use max(similarity) so if multiple similar users like the same park, you choose the highest similarity value

    RETURN p.publicId as publicId, max(similarity) as similarity
    ORDER BY similarity DESC
    LIMIT 10
    `,
      { username },
    );

    return result.records.map((record: { get: (arg0: string) => any }) => ({
      publicId: record.get("publicId"),
    }));
  } finally {
    console.log("Got node similarity recommendations, closing graph DB session");
    await session.close();
  }
};
