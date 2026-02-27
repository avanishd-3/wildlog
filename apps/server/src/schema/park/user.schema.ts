import { builder } from "@/builder";

const user = builder.simpleObject("User", {
  fields: (t) => ({
    id: t.string({
      nullable: false,
    }), // This is the publicId from the database, which is a UUID string
  }),
});

builder.queryField("me", (t) =>
  t.field({
    type: user,
    nullable: true, // Allow null when not logged in
    resolve: (_parent, _args, context) => {
      console.log("Resolving me query with context:", context);
      if (!context.user) {
        return null;
      }
      return {
        id: context.user.id,
      };
    },
  }),
);
