import { SQL, sql } from "drizzle-orm";
import {
  pgEnum,
  pgTable,
  index,
  integer,
  text,
  geometry,
  uuid,
  boolean,
} from "drizzle-orm/pg-core";

export const parkDesignationEnum = pgEnum("park_designation", [
  "National Seashore",
  "National Trail",
  "State Vehicular Recreation Area",
  "National Historic Site",
  "National Military Park",
  "National River",
  "State Natural Reserve",
  "National Parkway",
  "State Marine Reserve",
  "Memorial",
  "National Park",
  "Park Property",
  "National Military Park Site",
  "National Recreation Area",
  "National Lakeshore",
  "State Historic Site",
  "State Historic Park",
  "State Park",
  "National Historic Park",
  "National Reserve",
  "State Beach",
  "National Historical Park",
  "Point of Interest",
  "National Preserve",
  "National Memorial",
  "State Recreation Area",
  "National Monument",
]);

export const parkTypeEnum = pgEnum("park_type", ["National", "State"]);

export const park = pgTable(
  "park",
  {
    // Postgres recommends identity columns over serial types
    id: integer("id").primaryKey().generatedAlwaysAsIdentity(),

    // Public ID for external use (i.e., APIs)
    publicId: uuid("public_id").defaultRandom().notNull().unique(),
    name: text("name").notNull(),
    description: text("description").notNull(),
    designation: parkDesignationEnum("designation").notNull(),
    // Using PostGIS geometry type for spatial data
    // 4326 means use the latitude and longitude coordinate system
    // See: https://orm.drizzle.team/docs/guides/postgis-geometry-point

    // x is longitude and y is latitude, which is the standard for geographic coordinates.
    location: geometry("location", { type: "point", mode: "xy", srid: 4326 }).notNull(),
    states: text("states").notNull(),
    type: parkTypeEnum("type").notNull(),
    cost: integer("cost").notNull(),

    // Generated column for free parks (cost = 0)
    // See: https://orm.drizzle.team/docs/generated-columns

    // Postgres only supports stored, so these will be stored in the database and computed when the row is inserted or updated
    // Speeds up queries that filter for free parks since the value is pre-computed and indexed, rather than computed on the fly
    free: boolean("free")
      .generatedAlwaysAs((): SQL => sql`${park.cost} = 0`)
      .notNull(),
  },
  (t) => [
    index("spatial_index").using("gist", t.location), // Index on location to speed up spatial queries
  ],
);
