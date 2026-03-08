import "dotenv/config";
import { createEnv } from "@t3-oss/env-core";
import { z } from "zod";

export const env = createEnv({
  server: {
    DATABASE_URL: z.string().min(1),
    NEO4J_URL: z.string().min(1),
    NEO4J_USERNAME: z.string().min(1),
    NEO4J_PASSWORD: z.string().min(1),
    BETTER_AUTH_SECRET: z.string().min(32),
    BETTER_AUTH_URL: z.url(),
    S3_URL: z.string().min(1),
    GARAGE_RPC_SECRET: z.string().min(1),
    GARAGE_ACCESS_KEY: z.string().min(1),
    GARAGE_SECRET_KEY: z.string().min(1),
    NODE_ENV: z.enum(["development", "production", "test"]).default("development"),
  },
  runtimeEnv: process.env,
  emptyStringAsUndefined: true,
});
