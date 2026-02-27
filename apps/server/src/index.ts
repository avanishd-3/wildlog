import Fastify from "fastify";
import mercurius from "mercurius";
import { apiSchema } from "./schema/schema";

import { seed } from "@wildlog/db/seed";
import { getParkLocation } from "@wildlog/db/queries/test";

import { readFileSync } from "fs";

// Import embedding function to ensure the model is loaded at startup
import { computeEmbedding } from "@wildlog/embedding";
import { seedEmbeddings } from "@wildlog/db/seed-embed";
import { auth } from "@wildlog/auth";
import z from "zod";

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

      // If sign-up, check if username is available
      if (url.pathname == "/api/auth/sign-up/email") {
        console.log("Received sign-up request with body: ", request.body);
        const requestBody = SignUpRequest.safeParse(request.body);

        if (!requestBody.success) {
          console.log("Sign-up request validation failed: ", requestBody.error.message);
          reply.status(400).send({
            error: "Invalid sign-up request: " + requestBody.error.message,
            code: "INVALID_REQUEST",
          });
          return;
        }

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
    // Add user info to context if authenticated
    const session = await auth.api.getSession({
      headers: request.headers,
    });

    return {
      user: session?.user ?? null,
      session,
    };
  },
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
