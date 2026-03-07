import { fastify } from "fastify";
import { readFileSync } from "fs";
import { config } from "dotenv";
import fastifyHttpProxy from "@fastify/http-proxy";

const server = fastify({
  logger: false,
  https: {
    key: readFileSync("../../localhost-key.pem"),
    cert: readFileSync("../../localhost.pem"),
  },
});

// Read in env file from apps/server/.env
// Looks hacky but using env package leads to Zod validation errors, so this is fine. It'll fail properly, so it's as good as Zod anyway
config({ path: "../../apps/server/.env" });
const env = process.env;

if (!env.S3_URL) {
  console.error("S3_URL is not defined in the environment variables.");
  process.exit(1);
}

// const proxy = require('fastify-http-proxy');

server.register(fastifyHttpProxy, {
  upstream: env.S3_URL,
  prefix: "/", // Don't need any prefix, since proxy is on a different url than the main server (different port for local)
  http2: false, // Disable HTTP/2 if not needed
});

server.listen({ port: 3001 }, (err, address) => {
  if (err) {
    console.error("Error starting server:", err);
    process.exit(1);
  }
  console.log(`Reverse proxy server running at ${address}`);
});
