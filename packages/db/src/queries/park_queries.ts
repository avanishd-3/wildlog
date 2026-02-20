import { sql, and, cosineDistance, eq, desc, inArray } from "drizzle-orm";
import { db } from "..";
import { park, parkEmbedding } from "../schema";
import { computeEmbedding } from "@wildlog/embedding";

export const getParkMapRecommendations = async (
  x_min: number,
  x_max: number,
  y_min: number,
  y_max: number,
  filters?: any | null,
  where_clauses?: any | null,
) => {
  /**
   * Get list of parks to recommend for the user using a map.
   * If there are no search filters, default to bounding box + other filters
   * If there is a search query, use the embedding of the search query to find similar parks within the bounding box and other filters
   * Also, limit the number of results returned to 10 so the user doesn't have too many options
   */

  if (filters?.search) {
    // Need to handle search separately
    console.log("Search query: ", filters.search);

    // Compute trigrams for search query
    // Ignoring bounding box here b/c user wants a specific park and we should return it even if it's far from them
    const similarTrigramParks = await db
      .select({
        id: park.id,
        publicId: park.publicId,
        name: park.name,
        description: park.description,
        designation: park.designation,
        states: park.states,
        type: park.type,
        cost: park.cost,
        free: park.free,
        latitude: sql`ST_Y(${park.location})`,
        longitude: sql`ST_X(${park.location})`,
      })
      .from(park)
      // Word similarity is for trigram matching suitable for matching similarity for parts of words
      // Better than character similarity but needs lower threshold than you would think
      // With this threshold, yosem matches to Yosemite National Park alone
      // See: https://www.postgresql.org/docs/current/pgtrgm.html
      .where(sql`word_similarity(${park.name}, ${filters.search}) > 0.2`)
      .limit(5); // Limit to top 5 results so users don't have that many options

    if (similarTrigramParks.length > 0) {
      // If we have trigram results, we can return those without needing to do the embedding search, which is more expensive
      console.log("Search query has close trigram matches", filters.search);
      return similarTrigramParks;
    }

    const queryEmbeddingArray = await computeEmbedding(filters.search);

    const queryEmbedding = queryEmbeddingArray[0];

    if (!queryEmbedding) {
      // Should still return some results even if embedding fails
      return getParksByBoundingBox(x_min, x_max, y_min, y_max, where_clauses);
    }

    const cosineSimilarity = sql<number>`1 - (${cosineDistance(parkEmbedding.embedding, queryEmbedding)})`;

    // Get parks within bounding box and apply filters, then order by similarity to search query
    const filteredParks = await getParksByBoundingBox(x_min, x_max, y_min, y_max, where_clauses);

    const filteredParkIds = filteredParks.map((park) => park.id);

    // Fields returned should be superset of fields returned in getParksByBoundingBox query below so the GraphQL schema can be consistent
    return db
      .select({
        publicId: park.publicId,
        name: park.name,
        description: park.description,
        designation: park.designation,
        states: park.states,
        type: park.type,
        cost: park.cost,
        free: park.free,
        latitude: sql`ST_Y(${park.location})`,
        longitude: sql`ST_X(${park.location})`,
        similarity: cosineSimilarity,
      })
      .from(park)
      .innerJoin(parkEmbedding, eq(park.id, parkEmbedding.parkId)) // Join on internal id to improve cache performance
      .where(inArray(park.id, filteredParkIds))
      .orderBy((t) => desc(t.similarity))
      .limit(10); // Limit to top 10 results so users don't have that many options
  } else {
    return getParksByBoundingBox(x_min, x_max, y_min, y_max, where_clauses);
  }
};

const getParksByBoundingBox = async (
  x_min: number,
  x_max: number,
  y_min: number,
  y_max: number,
  filters?: any | null,
) => {
  /**
   * Get list of parks within a bounding box.
   * See: https://orm.drizzle.team/docs/guides/postgis-geometry-point
   *
   * Also supporting filters, which should be a list of where clauses to be applied to the query
   * Filter idea: https://brockherion.dev/blog/posts/dynamic-where-statements-in-drizzle/
   */

  const point = {
    x1: x_min,
    x2: x_max,
    y1: y_min,
    y2: y_max,
  };

  const boundingBoxClause = sql`ST_Within(${park.location}, ST_MakeEnvelope(${point.x1}, ${point.y1}, ${point.x2}, ${point.y2}, 4326))`;

  const where = filters ? [...filters, boundingBoxClause] : [boundingBoxClause];

  return db
    .select({
      id: park.id,
      publicId: park.publicId,
      name: park.name,
      description: park.description,
      designation: park.designation,
      states: park.states,
      type: park.type,
      cost: park.cost,
      free: park.free,
      latitude: sql`ST_Y(${park.location})`,
      longitude: sql`ST_X(${park.location})`,
    })
    .from(park)
    .where(and(...where))
    .orderBy(sql`RANDOM()`)
    .limit(15); // So people who zoom out heavily don't see a ton of parks
};
