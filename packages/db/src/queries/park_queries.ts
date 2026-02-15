import { sql, and } from "drizzle-orm";
import { db } from "..";
import { park } from "../schema";

export const getParksByBoundingBox = async (
  /**
   * Get list of parks within a bounding box.
   * See: https://orm.drizzle.team/docs/guides/postgis-geometry-point
   *
   * Also supporting filters, which should be a list of where clauses to be applied to the query
   * Filter idea: https://brockherion.dev/blog/posts/dynamic-where-statements-in-drizzle/
   */
  x_min: number,
  x_max: number,
  y_min: number,
  y_max: number,
  filters?: any | null,
) => {
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
      id: park.publicId,
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
    .where(and(...where));
};
