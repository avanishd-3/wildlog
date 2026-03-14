import { builder } from "@/builder";
import { getUserBucketListedParks, getUserLikedParks } from "@wildlog/db/queries/user-queries";
import { park } from "./park.schema";
import { getParkImageUrl } from "@wildlog/s3/park-url";

builder.queryField("likedParks", (t) =>
  t.field({
    description: "Get all parks that the current user has liked",
    type: [park],
    nullable: false,
    authScopes: {
      loggedIn: true,
    },
    resolve: async (_parent, _args, context) => {
      if (!context.user) {
        throw new Error("Unauthorized"); // Should not be possible due to authScopes, but just in case
      }
      const likedParks = await getUserLikedParks(context.user.id);
      return Promise.all(
        likedParks.map(async (park) => ({
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

builder.queryField("bucketListedParks", (t) =>
  t.field({
    description: "Get all parks that the current user has bucket listed",
    type: [park],
    nullable: false,
    authScopes: {
      loggedIn: true,
    },
    resolve: async (_parent, _args, context) => {
      if (!context.user) {
        throw new Error("Unauthorized"); // Should not be possible due to authScopes, but just in case
      }
      const bucketListedParks = await getUserBucketListedParks(context.user.id);
      return Promise.all(
        bucketListedParks.map(async (park) => ({
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
