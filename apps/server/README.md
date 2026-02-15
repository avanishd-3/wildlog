# Server

The server has the following endpoints.

- `/`: root endpoint, which is set to auto-redirect to /graphiql
- `/seed`: seed script for db (should **not** be used by client)
- `/graphql`: endpoint for all GraphQL requests
- `/graphiql`: UI for testing out queries (similar to Podman)
- `/graphdb`: redirects to Neo4J browser (which is on localhost:7474)

## File Structure

```text
/
├── src
│   ├── schema (GraphQL schema, not DB schema)
│   │   └── schema.ts (import all schema files and create server-side GraphQL schema)
│   ├── utils (Utilities)
│   ├── builder.ts (where pothos configuration is, add plugins here)
│   ├── index.ts (fastify server & mercurius configuration)
```


# GraphQL

The way we're using GraphQL in the server is code-first, which means that the TS code is the **source of truth** for what the schema is.
The server just outputs the schema file on startup for inspection and so the iOS client can use it (the iOS client is schema-first).

## Libraries

### Pothos

[Pothos](https://pothos-graphql.dev/) is used to have type-safe schema development. Since we're doing code first, Pothos = schema.

Currently, the only plugin is the [simple objects plugin](https://pothos-graphql.dev/docs/plugins/simple-objects), which makes it easier to create objects (as the name implies). It prevents you from needing a resolver for each field of an object, which is the most common case. However, if you need custom stuff for only specific fields or computed fields, use the regular object creator.

For example, when getting a park by id, the park returned by the db already contains the fields we want, so simple object is a good fit.

### Mercurius

[Mercurius](https://mercurius.dev/#/) is how the schema created w/ Pothos is actually executed.

## GraphQL-knowledge

Resolvers are just functions that tell GraphQL how to fetch data for a field (for queries) and insert it (for mutations).

GraphQL only resolves fields that are requested, which is nice because it reduces unnecessary work. It also only sends requested fields to the client, which reduces the over-sharing that can be an issue for Rest APIs.

This [article](https://omkarkulkarni.hashnode.dev/type-safe-graphql-server-with-pothos-formerly-giraphql) is pretty helpful to quickly understand how Pothos + GraphQl works. It uses Apollo instead of Mercurius, but the schema part is the same.