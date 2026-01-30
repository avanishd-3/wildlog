import Fastify from "fastify";
import mercurius from "mercurius";
import { apiSchema } from "./builder";

const app = Fastify({
  logger: true,
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

// Route to Neo4j Browser for convenience
app.get("/graphdb", async (_request, reply) => {
  reply.redirect("http://localhost:7474");
});
