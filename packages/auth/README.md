# Better-Auth

This package contains the configuration for [Better Auth](https://www.better-auth.com/).

With the current set up, Better Auth is integrated with Drizzle and can update the schema code when its configuration is updated. Drizzle will then generate migration files.

# Auth Flow

For our app, we're using cookie-based authentication to make things simpler. We don't need to worry about CORS since this is a first-party iOS app and we're not going to use web views (update better auth config and Fastify endpoint if this changes). We also don't need to worry about CSRF for the same reason.

Here's how auth will work.

1. Client login: POST /api/auth/sign-in, cookie gets attached & client sends in future requests
2. POST /graphql (cookie sent & resolvers enforce auth rules)

On app startup, the client can check if they have the cookie. If so, they can move to home screen. If not, they show log in screen.

# Updating Auth Config

In apps/server, you need to run ```pnpm dlx @auth@latest generate --config ../../packages/auth/src/index.ts```.

This will update auth.ts in the relational db schema. You then need to run (in the root directory, not apps/server) pnpm db:generate and pnpm db:migrate to translate the new schema to SQL and then to the DB.