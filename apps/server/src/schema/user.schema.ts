import { builder } from "@/builder";
import {
  bucketListPark,
  likePark,
  mutateReview,
  removeParkFromBucketList,
  unlikePark,
  updateBaseUserInfo,
  updateUserBio,
} from "@wildlog/db/mutations/user-mutations";

import {
  getUserReview,
  hasUserBucketListedPark,
  hasUserLikedPark,
} from "@wildlog/db/queries/user-queries";

const user = builder.simpleObject("User", {
  fields: (t) => ({
    id: t.string({
      nullable: false,
    }), // This is the userID from the database
    name: t.string({
      nullable: false,
    }),
    email: t.string({
      nullable: false,
    }),
    username: t.string({
      nullable: false,
    }),
    website: t.string({
      nullable: true,
    }),
    bio: t.string({
      nullable: true,
    }),
  }),
});

const review = builder.simpleObject("Review", {
  fields: (t) => ({
    rating: t.string({
      nullable: false,
    }),
    reviewText: t.string({
      nullable: true,
    }),
    visitedAt: t.string({
      nullable: true,
    }),
  }),
});

// ---- User queries ----

// Load review if it already exists for the park
builder.queryField("getUserReview", (t) =>
  t.field({
    type: review,
    args: {
      parkPublicId: t.arg.string({ required: true }),
    },
    authScopes: {
      loggedIn: true, // Only allow logged in users to see their reviews
    },
    resolve: async (_parent, _args, context) => {
      if (!context.user) {
        // Won't happen b/c of authScope (just to satisfy type checker)
        throw new Error("Not authenticated");
      }

      const result = await getUserReview(context.user.id, _args.parkPublicId);

      if (result === null || result === undefined) {
        return null;
      }
      return {
        reviewText: result.review,
        rating: result.rating,
        visitedAt: result.visitedAt ? result.visitedAt.toISOString() : null,
      };
    },
  }),
);

builder.queryField("isParkLiked", (t) =>
  t.field({
    type: "Boolean",
    args: {
      parkPublicId: t.arg.string({ required: true }),
    },
    authScopes: {
      loggedIn: true, // Only allow logged in users to see if they liked a park
    },
    resolve: async (_parent, _args, context) => {
      if (!context.user) {
        // Won't happen b/c of authScope (just to satisfy type checker)
        throw new Error("Not authenticated");
      }

      // Check if the user has liked the park in the database
      const isLiked = await hasUserLikedPark(context.user.id, _args.parkPublicId);

      console.log(
        `User ${context.user.username} has${isLiked ? "" : " not"} liked park with public ID ${_args.parkPublicId}`,
      ); // Debug log

      return isLiked;
    },
  }),
);

builder.queryField("isParkBucketListed", (t) =>
  t.field({
    type: "Boolean",
    args: {
      parkPublicId: t.arg.string({ required: true }),
    },
    authScopes: {
      loggedIn: true, // Only allow logged in users to see if they have bucket listed a park
    },
    resolve: async (_parent, _args, context) => {
      if (!context.user) {
        // Won't happen b/c of authScope (just to satisfy type checker)
        throw new Error("Not authenticated");
      }

      // Check if the user has bucket listed the park in the database
      const isBucketListed = await hasUserBucketListedPark(context.user.id, _args.parkPublicId);

      return isBucketListed;
    },
  }),
);

// ---- User mutations ----

builder.queryField("me", (t) =>
  t.field({
    type: user,
    nullable: true, // Allow null when not logged in
    resolve: (_parent, _args, context) => {
      console.log("Resolving 'me' query with user:", context.user);
      if (!context.user) {
        return null;
      }
      return {
        id: context.user.id,
        name: context.user.name,
        email: context.user.email,
        username: context.user.username,
        website: context.user.website,
        bio: context.user.bio,
      };
    },
  }),
);

builder.mutationField("updateBio", (t) =>
  t.field({
    type: user,
    args: {
      bio: t.arg.string({ required: true }),
    },
    authScopes: {
      loggedIn: true, // Only allow logged in users to update their bio
    },
    resolve: async (_parent, args, context) => {
      if (!context.user) {
        // Won't happen b/c of authScope (just to satisfy type checker)
        throw new Error("Not authenticated");
      }

      if (args.bio === context.user.bio) {
        // No change in bio, return current user
        return {
          id: context.user.id,
          name: context.user.name,
          email: context.user.email,
          username: context.user.username,
          website: context.user.website,
          bio: context.user.bio,
        };
      }

      // Update the user's bio in the database
      const updatedUserBio = (await updateUserBio(context.user.id, args.bio))[0]; // Drizzle returns an array, but since id is unique, there will only be 1 user

      if (updatedUserBio === undefined) {
        throw new Error("User bio update failed");
      }

      // Return the updated user (re-use everything but the bio so the db query can search less columns)
      return {
        id: context.user.id,
        name: context.user.name,
        email: context.user.email,
        username: context.user.username,
        website: context.user.website,
        bio: updatedUserBio.bio,
      };
    },
  }),
);

builder.mutationField("updateBaseUserInfo", (t) =>
  t.field({
    type: user,
    args: {
      name: t.arg.string({ required: true }),
      website: t.arg.string({ required: true }),
    },
    authScopes: {
      loggedIn: true, // Only allow logged in users to update their info
    },
    resolve: async (_parent, args, context) => {
      if (!context.user) {
        // Won't happen b/c of authScope (just to satisfy type checker)
        throw new Error("Not authenticated");
      }

      // Check if there are any changes to update, if not return current user
      if (args.name === context.user.name && args.website === context.user.website) {
        return {
          id: context.user.id,
          name: context.user.name,
          email: context.user.email,
          username: context.user.username,
          website: context.user.website,
          bio: context.user.bio,
        };
      }

      let method = "";

      if (args.name !== context.user.name && args.website !== context.user.website) {
        console.log("User requesting to update both name and website");
        method = "both";
      } else if (args.name !== context.user.name) {
        console.log("User requesting to update name only");
        method = "name";
      } else if (args.website !== context.user.website) {
        console.log("User requesting to update website only");
        method = "website";
      }

      // Update user info in the database
      const updatedUser = (
        await updateBaseUserInfo(
          context.user.id,
          method as "name" | "website" | "both",
          args.name,
          args.website,
        )
      )[0];

      if (updatedUser === undefined) {
        throw new Error("User info update failed");
      }

      // Return the updated user (re-use everything but the updated fields so the db query can search less columns)
      return {
        id: context.user.id,
        name: updatedUser.name,
        email: context.user.email,
        username: context.user.username,
        website: updatedUser.website,
        bio: context.user.bio,
      };
    },
  }),
);

// ---- Main stuff, likes, bucket list, reviews ----

builder.mutationField("likePark", (t) =>
  t.field({
    type: "Boolean",
    args: {
      parkPublicId: t.arg.string({ required: true }),
    },
    authScopes: {
      loggedIn: true, // Only allow logged in users to like parks
    },
    resolve: async (_parent, args, context) => {
      if (!context.user) {
        // Won't happen b/c of authScope (just to satisfy type checker)
        throw new Error("Not authenticated");
      }

      await likePark(context.user.id, context.user.username, args.parkPublicId);

      return true;
    },
  }),
);

builder.mutationField("addToBucketList", (t) =>
  t.field({
    type: "Boolean",
    args: {
      parkPublicId: t.arg.string({ required: true }),
    },
    authScopes: {
      loggedIn: true, // Only allow logged in users to add parks to bucket list
    },
    resolve: async (_parent, args, context) => {
      if (!context.user) {
        // Won't happen b/c of authScope (just to satisfy type checker)
        throw new Error("Not authenticated");
      }

      await bucketListPark(context.user.id, context.user.username, args.parkPublicId);

      return true;
    },
  }),
);

builder.mutationField("unlikePark", (t) =>
  t.field({
    type: "Boolean",
    args: {
      parkPublicId: t.arg.string({ required: true }),
    },
    authScopes: {
      loggedIn: true, // Only allow logged in users to unlike parks
    },
    resolve: async (_parent, args, context) => {
      if (!context.user) {
        // Won't happen b/c of authScope (just to satisfy type checker)
        throw new Error("Not authenticated");
      }

      await unlikePark(context.user.id, context.user.username, args.parkPublicId);

      return true;
    },
  }),
);

builder.mutationField("removeFromBucketList", (t) =>
  t.field({
    type: "Boolean",
    args: {
      parkPublicId: t.arg.string({ required: true }),
    },
    authScopes: {
      loggedIn: true, // Only allow logged in users to remove parks from bucket list
    },
    resolve: async (_parent, args, context) => {
      if (!context.user) {
        // Won't happen b/c of authScope (just to satisfy type checker)
        throw new Error("Not authenticated");
      }

      await removeParkFromBucketList(context.user.id, context.user.username, args.parkPublicId);

      return true;
    },
  }),
);

builder.mutationField("mutateReview", (t) =>
  t.field({
    type: "Boolean",
    args: {
      parkPublicId: t.arg.string({ required: true }),
      review: t.arg.string({ required: true }),
      rating: t.arg.string({ required: true }),
      visitedAt: t.arg.string({ required: true }), // ISO string of date, GraphQL just doesn't have a date type, will convert to Date in resolver
    },
    authScopes: {
      loggedIn: true, // Only allow logged in users to add reviews
    },
    resolve: async (_parent, args, context) => {
      console.log("Received mutateReview mutation with args:", args);
      if (!context.user) {
        // Won't happen b/c of authScope (just to satisfy type checker)
        throw new Error("Not authenticated");
      }

      try {
        await mutateReview(
          context.user.id,
          context.user.username,
          args.parkPublicId,
          args.review,
          args.rating,
          new Date(args.visitedAt),
        );
      } catch (error) {
        console.error("Error occurred while mutating review:", error);
        return false; // Indicate failure to mutate review
      }

      return true;
    },
  }),
);
