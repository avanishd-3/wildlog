import { builder } from "@/builder";

const user = builder.simpleObject("User", {
  fields: (t) => ({
    id: t.string({
      nullable: false,
    }), // This is the userID from the database
    username: t.string({
      nullable: false,
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
        username: context.user.username,
      };
    },
  }),
);
