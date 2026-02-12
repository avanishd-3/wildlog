import { sql } from "drizzle-orm";
import { db } from "..";
import { park } from "../schema";

export const getParkLocation = async () => {
  const result = db.execute(
    sql`SELECT ST_X(location) AS longitude, ST_Y(location) AS latitude FROM ${park} WHERE id = 1;`,
  );

  return result;
};
