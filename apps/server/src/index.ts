import Fastify from "fastify";
import mercurius from "mercurius";
import { apiSchema } from "./builder";

import { seed } from "@wildlog/db/seed";
import { getParkLocation } from "@wildlog/db/queries/test";

const app = Fastify({
  logger: false,
});

app.register(mercurius, {
  schema: apiSchema,
  graphiql: true, // Enable GraphQL UI
});

app.listen({ port: 3000 });

// Route get requests to the GraphiQL endpoint so loading the root URL doesn't show an error
app.get("/", async (_request, reply) => {
  reply.redirect("/graphiql");
});

// Seed route to seed database
app.get("/seed", async (_request, reply) => {
  try {
    await seed();
    reply.send({ message: "Database seeded successfully" });
  } catch (error) {
    console.error("Error seeding database:", error);
    reply.status(500).send({ error: "Failed to seed database" });
  }
});

app.get("/lat-checker", async (_request: any, reply: any) => {
  // Query db for id = 1 and return lat and long
  const result = await getParkLocation();

  reply.send({
    data: result.rows,
  });
});

// Route to Neo4j Browser for convenience
app.get("/graphdb", async (_request, reply) => {
  reply.redirect("http://localhost:7474");
});
