import { builder } from "@/builder";
import { park } from "./park.schema";
import { getForYouRecommendations, getPopularWithCommunity } from "@wildlog/graph-db/queries/user";
import { getParkImageUrl } from "@wildlog/s3/park-url";
import { getParksByPublicIds } from "@wildlog/db/queries/park-queries";

builder.queryField("getCommunityRecommendations", (t) =>
  t.field({
    description: "Community recommendations",
    type: [park],
    authScopes: {
      loggedIn: true, // Require authentication for this query
    },
    resolve: async (_parent, _args, context) => {
      // Get public ids from graph DB
      if (!context.user?.username) {
        throw new Error("User not authenticated"); // This should never happen due to authScopes, but we check just in case
      }

      const publicIds = await getPopularWithCommunity(context.user?.username).then((parks) =>
        parks.map((p) => p.publicId),
      );

      const parks = await getParksByPublicIds(publicIds);

      console.log("Got community recommendations");

      // Get park details from database based on public ids
      return Promise.all(
        parks.map(async (park) => ({
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
          imageUrl: await getParkImageUrl(park.publicId, park.imageId), // Get pre-signed URL for the park image from S3
        })),
      );
    },
  }),
);

builder.queryField("getForYouRecommendations", (t) =>
  t.field({
    description: "For you recommendations",
    type: [park],
    authScopes: {
      loggedIn: true, // Require authentication for this query
    },
    resolve: async (_parent, _args, context) => {
      // Get public ids from graph DB
      if (!context.user?.username) {
        throw new Error("User not authenticated"); // This should never happen due to authScopes, but we check just in case
      }
      const publicIds = (await getForYouRecommendations(context.user?.username)).map(
        (p) => p.publicId,
      );

      const parks = await getParksByPublicIds(publicIds);

      console.log("Got for you recommendations");

      // Get park details from database based on public ids
      return Promise.all(
        parks.map(async (park) => ({
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
          imageUrl: await getParkImageUrl(park.publicId, park.imageId), // Get pre-signed URL for the park image from S3
        })),
      );
    },
  }),
);
