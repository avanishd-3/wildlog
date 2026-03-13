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
// Explanation: Node similarity finds similar users based on their immediate neighbors
const getNodeSimilarityParkRecommendations = async (
  username: string,
): Promise<{ publicId: string; score: number }[]> => {
  const driver = await graphDBDriver();
  const session = driver.session({ database: process.env.NEO4J_DATABASE });

  // Create projection for link prediction algorithm
  // Projection is a virtual graph to speed up the algorithm
  // Pretend links are undirected for better recommendations (friends are bidirectional anyways)
  try {
    console.log(
      `Getting "For you" park recommendations for ${username} using node similarity algorithm`,
    );

    const result = await session.executeWrite(
      async (tx: { run: (arg0: string, arg1?: { username: string }) => any }) => {
        const existsResult = await tx.run(`
          CALL gds.graph.exists('userParkGraph') YIELD exists
          RETURN exists
        `);
        const exists = existsResult.records[0].get("exists");

        // Drop projection so new data can be included
        if (exists) {
          await tx.run(`CALL gds.graph.drop('userParkGraph') YIELD graphName`);
        }
        // Create projection for node similarity algorithm
        await tx.run(`
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
                },
                WANTS_TO_VISIT: {
                    type: 'WANTS_TO_VISIT',
                    orientation: 'UNDIRECTED'
                }
              }
          )
        `);

        return await tx.run(
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

          // Find parks similar users like or rated highly or want to visit
          MATCH (similarUser)-[:LIKES|RATED_HIGHLY|WANTS_TO_VISIT]->(p:Park)
          WHERE NOT (u)-[:LIKES|RATED_HIGHLY|VISITED]->(p) // Exclude parks the user already likes or rated highly or visited (since they might not want to visit again)

          // Use max(similarity) so if multiple similar users like the same park, you choose the highest similarity value

          RETURN p.publicId as publicId, max(similarity) as similarity
          ORDER BY similarity DESC
          LIMIT 10
          `,
          { username },
        );
      },
    );

    return result.records.map((record: { get: (arg0: string) => any }) => ({
      publicId: record.get("publicId"),
      score: record.get("similarity"),
    }));
  } finally {
    console.log("Got node similarity recommendations, closing graph DB session");
    await session.close();
  }
};

// Use Fast RP extended with cosine similarity to get parks with similar embeddings
// Not as explainable as node similarity but can give better recommendations
// Explanation: Node similarity is limited to immediate neighbors (i.e., users with similar friends and liked parks), but embeddings can capture more complex patterns in the graph
const getEmbeddingBasedParkRecommendations = async (
  username: string,
): Promise<{ publicId: string; score: number }[]> => {
  const driver = await graphDBDriver();
  const session = driver.session({ database: process.env.NEO4J_DATABASE });

  // Create projection for embedding algorithm
  // Projection is a virtual graph to speed up the algorithm
  // Pretend links are undirected for better recommendations (friends are bidirectional anyways)
  try {
    console.log(`Creating graph projection for embedding-basedrecommendations for ${username}`);

    const existsResult = await session.run(`
      CALL gds.graph.exists('userParkGraphEmbedding') YIELD exists
      RETURN exists
    `);
    const exists = existsResult.records[0].get("exists");

    // Drop projection so new data can be included
    if (exists) {
      await session.run(`CALL gds.graph.drop('userParkGraphEmbedding') YIELD graphName`);
    }

    console.log(
      `Getting "For you" park recommendations for ${username} using embedding-based algorithm`,
    );

    // Create projection for embedding algorithm
    // Making it separate so we can tune it differently to the node similarity projection if needed (can create new signals w/ ML later, just like adding new columns in traditional feature engineering)

    // Using transaction for safety (mutate and knn also have to be in different queries)
    const result = await session.executeWrite(
      async (tx: { run: (arg0: string, arg1?: { username: string }) => any }) => {
        await tx.run(`
        CALL gds.graph.project(
            'userParkGraphEmbedding',
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
              },
              WANTS_TO_VISIT: {
                  type: 'WANTS_TO_VISIT',
                  orientation: 'UNDIRECTED'
              }
          }
      )
      `);

        // Create embeddings based on graph projection above (add them as a property to each node for knn to use)
        await tx.run(`CALL gds.fastRP.mutate('userParkGraphEmbedding', {
        embeddingDimension: 64,
        randomSeed: 42,
        mutateProperty: 'fastrp-embedding'
        })

        YIELD nodePropertiesWritten; // Ensure embeddings are created, don't need the result of this call`);

        // Use KNN with cosine similarity to find similar users based on their embeddings
        // Then find parks those similar users like or rated highly, excluding parks the user already likes or rated highly
        return await tx.run(
          `
        // Find node id for the user
        MATCH (u:User {username:$username})


        // Use KNN with cosine similarity to find similar users based on embeddings
        CALL gds.knn.stream('userParkGraphEmbedding', {
          nodeProperties: 'fastrp-embedding',
          topK: 50
        })
        YIELD node1, node2, similarity

        // Convert node ids back to real nodes
        WITH u, gds.util.asNode(node1) AS sourceUser, gds.util.asNode(node2) AS similarUser, similarity

        // Find similar users based on embeddings, excluding the user themselves (since they are 100% similar to themselves)
        WHERE sourceUser:User AND similarUser:User
        AND sourceUser.username = $username 
        AND similarUser.username <> $username

        // Find parks similar users like or rated highly or want to visit
        MATCH (similarUser)-[:LIKES|RATED_HIGHLY|WANTS_TO_VISIT]->(p:Park)
        WHERE NOT (u)-[:LIKES|RATED_HIGHLY|VISITED]->(p) // Exclude parks the user already likes or rated highly or visited (since they might not want to visit again)

        // Use max(similarity) so if multiple similar users like the same park, you choose the highest similarity value

        RETURN p.publicId as publicId, max(similarity) as similarity
        ORDER BY similarity DESC
        LIMIT 10
        `,
          { username },
        );
      },
    );

    return result.records.map((record: { get: (arg0: string) => any }) => ({
      publicId: record.get("publicId"),
      score: record.get("similarity"),
    }));
  } finally {
    console.log("Got emebdding-based recommendations, closing graph DB session");
    await session.close();
  }
};

// Combine recommendations from both algorithms, removing duplicates
export const getForYouRecommendations = async (
  /**
   * @description Get personalized "For you" park recommendations for the user based on node similarity and embeddings
   * @argument username - The username of the user to get recommendations for
   * @return Top 10 park recommendations, ordered by their score (highest is better)
   */
  username: string,
): Promise<{ publicId: string }[]> => {
  // Get recommendations from both algorithms and combine results, removing duplicates
  const [nodeSimilarityRecs, embeddingRecs] = await Promise.all([
    getNodeSimilarityParkRecommendations(username),
    getEmbeddingBasedParkRecommendations(username),
  ]);

  const combinedRecs = [...nodeSimilarityRecs, ...embeddingRecs];
  const uniqueRecsMap: Record<string, { publicId: string; score: number }> = {};
  combinedRecs.forEach((rec) => {
    uniqueRecsMap[rec.publicId] = rec; // This will automatically deduplicate based on publicId
  });

  // For each unique recommendation, use formula of 0.6 * embeddings + 0.4 * node similarity for final score
  // Embeddings are more powerful but less explainable, so we want to weight them more

  Object.values(uniqueRecsMap).forEach((rec) => {
    const nodeSimRec = nodeSimilarityRecs.find((r) => r.publicId === rec.publicId);
    const embeddingRec = embeddingRecs.find((r) => r.publicId === rec.publicId);

    const nodeSimScore = nodeSimRec ? nodeSimRec.score : 0;
    const embeddingScore = embeddingRec ? embeddingRec.score : 0;

    rec.score = 0.4 * nodeSimScore + 0.6 * embeddingScore;
  });

  // Order results by their score (calculated using above formula)
  // Choose only top 10 to align with the community recommendations
  const orderedRecs = Object.values(uniqueRecsMap).sort((a, b) => b.score - a.score); // Sorting from highest to lowest score (sort function should return negative if first value is less than the second, but we want higher scores first, so we do b - a)
  const topRecs = orderedRecs.slice(0, 10); // Slice is exclusive, so this is 10 items
  return topRecs.map((rec) => ({ publicId: rec.publicId }));
};
