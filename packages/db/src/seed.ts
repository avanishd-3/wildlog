import path from "path";
import { parse } from "csv-parse";
import { createReadStream } from "fs";

import { sql } from "drizzle-orm";
import { park } from "./schema/park";

import { db } from "./index";

export const seed = async () => {
  const csvPath = path.resolve("../../apps/data/park_data_21126_1301.csv");
  console.log(`Seeding database from CSV file at: ${csvPath}`);

  // See https://www.importcsv.com/blog/typescript-csv-parser for parsing logic.
  interface Park {
    name: string;
    description: string;
    designation: string;
    latitude: number;
    longitude: number;
    states: string;
    type: string;
    cost: number;
  }

  const parks: Park[] = [];

  createReadStream(csvPath)
    .pipe(
      parse({
        delimiter: ",",
        columns: true,
        skip_empty_lines: true,
        // Convert cost column to number
        cast: (value, context) => {
          if (
            context.column === "cost" ||
            context.column === "latitude" ||
            context.column === "longitude"
          ) {
            const num = parseInt(value, 10);
            return Number.isNaN(num) ? 0 : num;
          }
          return value;
        },
      }),
    )
    .on("data", (row: Park) => {
      parks.push(row);
    })
    .on("end", async () => {
      console.log(`Parsed ${parks.length} parks from CSV.`);

      const rows = parks.map((r) => {
        const { name, description, designation, latitude, longitude, states, type, cost } = r;

        // X longitude, Y latitude, SRID 4326 tells PostGIS this is a GPS coordinate
        const location = sql`ST_SetSRID(ST_MakePoint(${longitude}::double precision, ${latitude}::double precision), 4326)`;

        return {
          name,
          description,
          designation,
          location,
          states,
          type,
          cost,
        };
      });

      // console.log("Rows: ", rows);
      console.log(`Prepared ${rows.length} park records for insertion.`);

      // Insert with 1 single transaction (less than 800 rows, so should be fine)
      await db.transaction(async (tx) => {
        await tx.insert(park).values(
          rows.map(
            (r: {
              name: any;
              description: any;
              designation: any;
              location: any;
              states: any;
              type: any;
              cost: any;
            }) => ({
              name: r.name,
              description: r.description,
              designation: r.designation,
              location: r.location,
              states: r.states,
              type: r.type,
              cost: r.cost,
            }),
          ),
        );
      });
    })
    .on("error", (err) => {
      console.error("Error parsing CSV:", err.message);
    });
};
