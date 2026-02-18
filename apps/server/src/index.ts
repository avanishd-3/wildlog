import Fastify from "fastify";
import mercurius from "mercurius";
import { apiSchema } from "./schema/schema";

import { seed } from "@wildlog/db/seed";
import { getParkLocation } from "@wildlog/db/queries/test";

import { readFileSync } from "fs";

// Import embedding function to ensure the model is loaded at startup
import { computeEmbedding } from "@wildlog/embedding";

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

app.get("/lat-checker", async (_request: any, reply: any) => {
  // Query db for id = 1 and return lat and long
  const result = await getParkLocation();

  reply.send({
    data: result.rows,
  });
});

app.get("/embedding-test", async (_request: any, reply: any) => {
  const sentences = [
    "The cat is on the table.",
    "A dog is in the garden.",
    "The sun is shining brightly.",
  ];

  try {
    const embeddings = await computeEmbedding(sentences);
    reply.send({ embeddings });
  } catch (error) {
    console.error("Error computing embeddings:", error);
    reply.status(500).send({ error: "Failed to compute embeddings" });
  }
});

// Route to Neo4j Browser for convenience
app.get("/graphdb", async (_request, reply) => {
  reply.redirect("http://localhost:7474");
});
