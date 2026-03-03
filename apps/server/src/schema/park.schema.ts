import { createGraphQLEnumFromPgEnum } from "@/utils/create-graphql-enum";
import { builder } from "@/builder";
import { parkDesignationEnum, parkTypeEnum } from "@wildlog/db/schema/park";

import { getParkMapRecommendations } from "@wildlog/db/queries/park-queries";
import { getParksFilters } from "@wildlog/db/utils/get-park-query-filters";

const ParkDesignationEnum = createGraphQLEnumFromPgEnum(
  builder,
  "ParkDesignationEnum",
  parkDesignationEnum.enumValues,
);
const ParkTypeEnum = createGraphQLEnumFromPgEnum(builder, "ParkTypeEnum", parkTypeEnum.enumValues);

const ParkCostFilter = builder.enumType("ParkCostFilterEnum", {
  values: ["Free", "Low", "Medium", "High"] as const,
});

const park = builder.simpleObject("Park", {
  fields: (t) => ({
    id: t.string({
      nullable: false,
    }), // This is the publicId from the database, which is a UUID string
    name: t.string({
      nullable: false,
    }),
    description: t.string({
      nullable: false,
    }),
    designation: t.field({
      type: ParkDesignationEnum,
      nullable: false,
    }),
    latitude: t.float({
      nullable: true,
    }),
    longitude: t.float({
      nullable: true,
    }),
    states: t.string({
      nullable: false,
    }),
    type: t.field({
      type: ParkTypeEnum,
      nullable: false,
    }),
    cost: t.int({
      nullable: false,
    }),
    free: t.boolean({
      nullable: false,
    }),
  }),
});

export const parkFilters = builder.inputType("ParkFiltersInput", {
  fields: (t) => ({
    search: t.string(),
    type: t.field({ type: ParkTypeEnum }),
    cost: t.field({ type: ParkCostFilter }),
  }),
});

builder.queryField("getParkMapRecommendations", (t) =>
  t.field({
    type: [park],
    args: {
      x_min: t.arg.float({ required: true }),
      y_min: t.arg.float({ required: true }),
      x_max: t.arg.float({ required: true }),
      y_max: t.arg.float({ required: true }),
      filters: t.arg({ type: parkFilters, required: false }),
    },
    authScopes: {
      loggedIn: true, // Require authentication for this query
    },
    resolve: async (_, args) => {
      console.log("Received filters:", args.filters);
      const whereClauses = getParksFilters(args.filters);
      const parks = await getParkMapRecommendations(
        args.x_min,
        args.x_max,
        args.y_min,
        args.y_max,
        args.filters,
        whereClauses,
      );
      return parks.map((park) => ({
        id: park.publicId,
        name: park.name,
        description: park.description,
        designation: park.designation,
        latitude: typeof park.latitude === "number" ? park.latitude : null,
        longitude: typeof park.longitude === "number" ? park.longitude : null,
        states: park.states,
        type: park.type,
        cost: park.cost,
        free: park.free,
      }));
    },
  }),
);
