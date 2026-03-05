import Fastify from "fastify";
import mercurius from "mercurius";
import { apiSchema } from "./schema/schema";

import { getDuplicateParks, seed } from "@wildlog/db/seed";
import { getParkLocation } from "@wildlog/db/queries/test";

import { readFileSync } from "fs";

// Import embedding function to ensure the model is loaded at startup
import { computeEmbedding } from "@wildlog/embedding";
import { seedEmbeddings } from "@wildlog/db/seed-embed";
import { auth } from "@wildlog/auth";
import z from "zod";

// Make sure to close neo4j driver on shutdown
import { closeDriver } from "@wildlog/graph-db";
import { insertParksIntoGraph } from "@wildlog/graph-db/seed";
import { createUser } from "@wildlog/graph-db/mutations/create-user";

const app = Fastify({
  logger: false,
  https: {
    key: readFileSync("localhost-key.pem"),
    cert: readFileSync("localhost.pem"),
  },
});

// Different than Better Auth docs, but what we mandate in UI
const SignUpRequest = z.object({
  email: z.email(),
  name: z.string().min(1),
  password: z.string().min(8),
  username: z
    .string()
    .min(3)
    .max(20)
    .regex(/^[a-zA-Z0-9_]+$/),
});

// Register authentication endpoint
// See: https://www.better-auth.com/docs/integrations/fastify#prerequisites
app.route({
  method: ["GET", "POST"],
  url: "/api/auth/*",
  async handler(request, reply) {
    try {
      // Construct request URL
      const url = new URL(request.url, `https://${request.headers.host}`);

      // Convert Fastify headers to standard Headers object
      const headers = new Headers();
      Object.entries(request.headers).forEach(([key, value]) => {
        if (value) headers.append(key, value.toString());
      });

      // Create Fetch API-compatible request
      const req = new Request(url.toString(), {
        method: request.method,
        headers,
        ...(request.body ? { body: JSON.stringify(request.body) } : {}),
      });

      const requestBody = SignUpRequest.safeParse(request.body);

      if (!requestBody.success) {
        console.log("Request validation failed: ", requestBody.error.message);
        reply.status(400).send({
          error: "Invalid request: " + requestBody.error.message,
          code: "INVALID_REQUEST",
        });
        return;
      }

      // If sign-up, check if username is available
      if (url.pathname == "/api/auth/sign-up/email") {
        console.log("Received sign-up request with username: ", requestBody.data.username);
        console.log(`Checking availability for username: ${requestBody.data.username}`);

        const isAvailableResponse = await auth.api.isUsernameAvailable({
          body: {
            username: requestBody.data.username,
          },
        });

        if (!isAvailableResponse?.available) {
          console.log(`Username ${requestBody.data.username} is already taken`);
          reply.status(409).send({
            error: "Username is already taken",
            code: "USERNAME_TAKEN",
          });
          return;
        }
      }

      // Log account deletion
      if (url.pathname == "/api/auth/delete-user") {
        console.log("Received account deletion request for user: ", requestBody.data.email);
      }

      // Process authentication request
      const response = await auth.handler(req);

      console.log("Auth response is ", response);

      // Forward response to client
      reply.status(response.status);
      response.headers.forEach((value, key) => reply.header(key, value));
      reply.send(response.body ? await response.text() : null);
    } catch (error) {
      app.log.error("Authentication Error:", error as undefined); // Added manual type assertion to avoid TS error about no overload
      reply.status(500).send({
        error: "Internal authentication error",
        code: "AUTH_FAILURE",
      });
    }
  },
});

app.register(mercurius, {
  schema: apiSchema,
  graphiql: true, // Enable GraphQL UI
  context: async (request, _reply) => {
    // Add user info to context if authenticated (per-request)
    const session = await auth.api.getSession({
      headers: request.headers,
    });

    return {
      user: session?.user ?? null,
      session,
    };
  },
});

// Route get requests to the GraphiQL endpoint so loading the root URL doesn't show an error
app.get("/", async (_request, reply) => {
  reply.redirect("/graphiql");
});

// Seed route to seed database
// Seed relational and graph databases
// Split up for better error messages (also graph DB seeding depends on relational DB seeding)
app.get("/seed", async (_request, reply) => {
  try {
    await seed();
  } catch (error) {
    console.error("Error seeding database:", error);
    reply.status(500).send({ error: "Failed to seed relational database" });
  }

  try {
    await insertParksIntoGraph();
    reply.send({ message: "Relational and graph database seeded successfully" });
  } catch (error) {
    console.error("Error seeding graph database:", error);
    reply
      .status(500)
      .send({ error: "Relational seeded successfully, but failed to seed graph database" });
  }
});

app.get("/duplicates", async (_request, reply) => {
  // Find all duplicate parks by name in the relational database and return them
  try {
    const result = await getDuplicateParks();
    reply.send({ data: result.rows });
  } catch (error) {
    console.error("Error finding duplicates:", error);
    reply.status(500).send({ error: "Failed to find duplicate parks" });
  }
});

app.get("/seed-embed", async (_request, reply) => {
  // Takes a few seconds
  try {
    await seedEmbeddings();
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

process.on("SIGTERM", () => {
  console.log("Received SIGTERM, shutting down gracefully...");
  app.close().then(() => {
    console.log("Server closed");
    process.exit(0);
  });
});

process.on("SIGINT", () => {
  console.log("Received SIGINT, shutting down gracefully...");
  app.close().then(() => {
    console.log("Server closed");
    process.exit(0);
  });
});

// ---- App Hooks -----

app.addHook("onClose", async (_instance) => {
  console.log("Fastify instance is closing, closing Neo4j driver...");
  await closeDriver();
});

// Graph DB insert can be slow, so do it after successful sign-up to avoid slowing down auth flow
app.addHook("onResponse", async (request, reply) => {
  // If user signed up, insert them into graph db
  if (request.url === "/api/auth/sign-up/email" && reply.statusCode === 200) {
    console.log("Inserting new user into graph database...");
    const requestBody = SignUpRequest.safeParse(request.body);

    if (!requestBody.success) {
      // Won't happen if reply is 200, just to satisfy type checker
      console.log("Sign-up request validation failed: ", requestBody.error.message);
      return; // Don't attempt to insert into graph DB if validation fails
    }

    try {
      await createUser(requestBody.data.username);
      console.log("User inserted into graph database successfully");
    } catch (error) {
      console.error("Error inserting user into graph database:", error);
    }
  }
});

// ---- Start Server ----

// This needs to be at the end to ensure everything is registered before the app starts
app.listen({ port: 3000 }, (err, address) => {
  if (err) {
    console.error("Error starting server:", err);
    process.exit(1);
  }
  console.log(`Server is running at ${address}`);
});
