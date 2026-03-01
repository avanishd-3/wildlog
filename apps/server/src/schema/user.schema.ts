import { builder } from "@/builder";
import { updateUserBio } from "@wildlog/db/mutations/user-mutations";

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
        // Should not happen, but just in case
        throw new Error("User not found");
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
