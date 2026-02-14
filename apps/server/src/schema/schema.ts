import { lexicographicSortSchema, printSchema } from "graphql";
import { builder } from "../builder";
import { writeFileSync } from "fs";
import path from "path";

import "./park/park.schema";

export const apiSchema = builder.toSchema({});

const schemaAsString = printSchema(lexicographicSortSchema(apiSchema));

// Write the generated schema to a file for iOS client to use for code-gen

writeFileSync(path.join(process.cwd(), "schema.graphql"), schemaAsString);
