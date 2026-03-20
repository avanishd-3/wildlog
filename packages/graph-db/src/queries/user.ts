import { graphDBDriver } from "..";

// Define a session type b/c Neo4j driver is not typed (yay)
type SessionLike = {
  run: (query: string, params?: Record<string, unknown>) => Promise<unknown>;
};

// Thanks neo4j for not having typing (jank but should work)
const isIgnorableGdsError = (error: unknown, allowedSnippets: string[]): boolean => {
  if (!(error instanceof Error)) return false;
  const msg = error.message.toLowerCase();
  return allowedSnippets.some((snippet) => msg.includes(snippet.toLowerCase()));
};

const safeDropProjection = async (session: SessionLike, graphName: string): Promise<void> => {
  try {
    await session.run("CALL gds.graph.drop($graphName, false) YIELD graphName", { graphName }); // Use false to fail silently if projection doesn't exist
  } catch (error) {
    if (isIgnorableGdsError(error, ["does not exist", "no graph with name"])) {
      // Yes the fail silently will still fail, so we should ignore these
      return;
    }
    throw error;
  }
};

const createUserParkProjection = async (session: SessionLike, graphName: string): Promise<void> => {
  await session.run(
    `
      CALL gds.graph.project(
        $graphName,
        ['User', 'Park'],
        {
          FRIEND: { type: 'FRIEND', orientation: 'UNDIRECTED' },
          LIKES: { type: 'LIKES', orientation: 'UNDIRECTED' },
          RATED_HIGHLY: { type: 'RATED_HIGHLY', orientation: 'UNDIRECTED' },
          VISITED: { type: 'VISITED', orientation: 'UNDIRECTED' },
          WANTS_TO_VISIT: { type: 'WANTS_TO_VISIT', orientation: 'UNDIRECTED' }
        }
      )
    `,
    { graphName },
  );
};

// Create unique projection names and node properties to avoid race conditions from concurrent user queries
const uniqueSuffix = (): string => `${Date.now()}_${Math.floor(Math.random() * 1_000_000)}`;

// Get list of parks liked or reviewed highly by the user's friends and friends-of-friends, ordered by most liked/reviewed first
// NOTE: Not adding wants to visit b/c a like means they probably visited the park. Wanted means they didn't visit
// I think popular with community should only be for parks that the friend network has actually visited.
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

// IMPORTANT: Projections are global, **not** per session or per-transaction, so we need to have unique names and drop them after. Transactions in Neo4j are **not** like SQL. They operate on the same global graph state.

// Use node similarity for link prediction
// Node similarity seems to be more modern that Adamic Adar and jaccard
// Had issues with those 2, also performance with those is bad (no streams)
// Explanation: Node similarity finds similar users based on their immediate neighbors
const getNodeSimilarityParkRecommendations = async (
  username: string,
): Promise<{ publicId: string; score: number }[]> => {
  const driver = await graphDBDriver();
  const session = driver.session({ database: process.env.NEO4J_DATABASE });
  const projectionName = `userParkGraph_${username}_${uniqueSuffix()}`; // Have unique projection name to avoid race condition

  // Create projection for link prediction algorithm
  // Projection is a virtual graph to speed up the algorithm
  // Pretend links are undirected for better recommendations (friends are bidirectional anyways)
  try {
    console.log(
      `Getting "For you" park recommendations for ${username} using node similarity algorithm`,
    );

    await createUserParkProjection(session, projectionName);

    // Do node similarity calculation
    const result = await session.run(
      `
      MATCH (u:User {username:$username})

      // Stream for better performance and to handle larger graphs
      // See: https://neo4j.com/docs/graph-data-science/current/algorithms/node-similarity/#algorithms-node-similarity-examples-stream
      CALL gds.nodeSimilarity.stream($projectionName, {
        topK: 50
      })
      YIELD node1, node2, similarity

      // Convert node ids back to real nodes
      WITH u, gds.util.asNode(node1) AS sourceUser, gds.util.asNode(node2) AS similarUser, similarity

      // Exclude the user themselves (since they are 100% similar to themselves)
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
      { username, projectionName },
    );

    return result.records.map((record: { get: (arg0: string) => any }) => ({
      publicId: record.get("publicId"),
      score: record.get("similarity"),
    }));
  } finally {
    // Hopefully this prevents issues
    await safeDropProjection(session, projectionName);
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
  const projectionName = `userParkGraphEmbedding_${username}_${uniqueSuffix()}`;
  const mutateProperty = `fastrp_embedding_${uniqueSuffix()}`; // Had issues where node property already existed, this should fix that

  // Create projection for embedding algorithm
  // Projection is a virtual graph to speed up the algorithm
  // Pretend links are undirected for better recommendations (friends are bidirectional anyways)
  try {
    console.log(
      `Getting "For you" park recommendations for ${username} using embedding-based algorithm`,
    );

    await createUserParkProjection(session, projectionName);

    await session.run(
      `
      CALL gds.fastRP.mutate($projectionName, {
        embeddingDimension: 64,
        randomSeed: 42,
        mutateProperty: $mutateProperty
      })
      YIELD nodePropertiesWritten
      RETURN nodePropertiesWritten
      `,
      { projectionName, mutateProperty },
    );

    const result = await session.run(
      `
        // Find node id for the user
        MATCH (u:User {username:$username})


        // Use KNN with cosine similarity to find similar users based on embeddings
        CALL gds.knn.stream($projectionName, {
          nodeProperties: $mutateProperty,
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
      { username, projectionName, mutateProperty },
    );

    return result.records.map((record: { get: (arg0: string) => any }) => ({
      publicId: record.get("publicId"),
      score: record.get("similarity"),
    }));
  } finally {
    // Hopefully this prevents issues
    await safeDropProjection(session, projectionName);
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
