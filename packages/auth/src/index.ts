import { db } from "@wildlog/db";
import * as schema from "@wildlog/db/schema/auth";
import { betterAuth } from "better-auth";
import { drizzleAdapter } from "better-auth/adapters/drizzle";
import { username, openAPI } from "better-auth/plugins";

export const auth = betterAuth({
  database: drizzleAdapter(db, {
    provider: "pg",

    schema: schema,
  }),
  trustedOrigins: ["*"], // Allow all origins for mobile app (don't need to worry about CORS)
  emailAndPassword: {
    enabled: true,
  },
  disabledPaths: ["/is-username-available"], // Do not allow usernames to be enumerated
  advanced: {
    defaultCookieAttributes: {
      sameSite: "none",
      secure: true,
      httpOnly: true,
    },
    disableOriginCheck: true, // Disable origin check for mobile app (don't need to worry about CORS)
  },
  plugins: [
    username(), // Allow people to log in with their username instead of email address
    openAPI(), // Generate OpenAPI spec for auth endpoints
  ],
  user: {
    deleteUser: {
      // For real app, you would need to send an email to confirm deletion
      enabled: true,
    },
    additionalFields: {
      website: {
        type: "string",
        required: false,
      },
      bio: {
        type: "string",
        required: false,
      },
    },
  },
});
