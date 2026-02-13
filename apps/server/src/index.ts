import Fastify from "fastify";
import mercurius from "mercurius";
import { apiSchema } from "./schema/schema";

import { seed } from "@wildlog/db/seed";

import { readFileSync } from "fs";

const app = Fastify({
  logger: false,
  https: {
    key: readFileSync("localhost-key.pem"),
    cert: readFileSync("localhost.pem"),
  },
});

app.register(mercurius, {
  schema: apiSchema,
  graphiql: true, // Enable GraphQL UI
});

app.listen({ port: 3000 }, (err, address) => {
  if (err) {
    console.error("Error starting server:", err);
    process.exit(1);
  }
  console.log(`Server is running at ${address}`);
});

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

// Route to Neo4j Browser for convenience
app.get("/graphdb", async (_request, reply) => {
  reply.redirect("http://localhost:7474");
});
