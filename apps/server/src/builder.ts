import SchemaBuilder from "@pothos/core";

import SimpleObjectsPlugin from "@pothos/plugin-simple-objects";

export const builder = new SchemaBuilder({
  plugins: [SimpleObjectsPlugin],
});

// Create root Query and Mutation type
// Need this to prevent missing root type error
builder.queryType({});
builder.mutationType({});
