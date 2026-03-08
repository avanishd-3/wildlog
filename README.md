# wildlog

This project was created with [Better-T-Stack](https://github.com/AmanVarshney01/create-better-t-stack), a modern TypeScript stack that combines Fastify, and more.

## Tech Stack

### Languages

- **TypeScript** - For type safety and improved developer experience
- **Swift** - For iOS app (using SwiftUI and Swift Data)

### Server

- **Fastify** - Fast, low-overhead web framework
- **Node.js** - Runtime environment

### Database

- **PostgreSQL** - Relational Database engine
- **Neo4J** - Graph DB
- **Drizzle** - TypeScript-first ORM (for PostgreSQL only)

### GraphQL

- **Pothos** - TS schema builder for GraphQL
- **Mercurius** - Easily run Graph QL server on Fastify
- **Apollo client** - GraphQL client for iOS

### Other

- **Authentication** - Better-Auth
- **Husky** - Git hooks for code quality
- **Oxlint** - Oxlint + Oxfmt (linting & formatting)
- **Turborepo** - Optimized monorepo build system

## Getting Started

First, install the dependencies:

```bash
pnpm install
```

## Environment Variable Setup
You need to add a .env file in apps/server with all the relevant environment variables. See `packages/env/src/server.ts` for the environment variables you need to set.
For Better Auth secret, run `openssl rand -base64 32`.

For Garage RPC secret, run `openssl rand -hex 32`.

For Better Auth url, you can default to http://localhost:3000 for local development.
For S3 url, you can default to http://localhost:3900 for local development.

## Server Setup

Because iOS apps can only make HTTPS requests (technically you can disable this, but your app will not be approved), the server is configured to **require** a certificate and key to run. If you try to run the server without these, the server will error.

To create a local SSL certificate, follow these instructions.

1. Install [mkcert](https://github.com/FiloSottile/mkcert)
2. Run `mkcert -install`
3. Run `mkcert -cert-file localhost.pem -key-file localhost-key.pem localhost 127.0.0.01 ::1`
4. Put localhost.pem and localhost-key.pem in the root directory (where this README is)

## Database Setup

This project uses PostgreSQL with Drizzle ORM and Neo4j.

1. Update your `apps/server/.env` file with your connection details as mentioned above.

2. Apply the schema to your PostgreSQL database:

```bash
pnpm run db:migrate
```

Then, run the development server:

```bash
pnpm run dev
```

The API is running at [https://localhost:3000](https://localhost:3000).

### Seed Database
1. Go to the /seed endpoint on the server.

## S3 Setup

**Important**: This must be done after seeding the database.

While running the S3 docker container (can use `pnpm dev` from root)

1. Go to the admin UI (http://localhost:3909/)
2. Go the keys tab and create a key.
3. In your apps/server .env file, set GARAGE_ACCESS_KEY = Key ID from Garage and GARAGE_SECRET_KEY = Secret Key from Garage
4. Go to the buckets tab and create a bucket called `park-images`
5. In the park-images bucket, go to manage -> permissions and give your key (created in step 2) read, write, and owner permissions.
6. Go to [https://localhost:3000/seed-s3](https://localhost:3000/seed-s3)

Now, you can run the s3 seed script.

## iOS Setup

**Important**: Minimum Xcode 16.3

Read the README in the apps/ios folder for instructions on how to add the certificate to the iOS simulator.

## Git Hooks and Formatting

- Initialize hooks: `pnpm run prepare`

## Project Structure

```
wildlog/
├── apps/
│   └── server/      # Backend API (Fastify)
│   └── ios/         # iOS app (SwiftUI)
├── packages/
│   ├── auth/        # Authentication configuration & logic
│   ├── config/      # Base config
│   ├── env/         # Make build fail if missing any env vars
│   └── db/          # Relational database schema & queries
│   └── graph-db/    # Graph database queries
```

## Available Scripts

- `pnpm run dev`: Start all applications in development mode
- `pnpm run build`: Build all applications
- `pnpm run dev:server`: Start only the server
- `pnpm run check-types`: Check TypeScript types across all apps
- `pnpm run db:push`: Push schema changes to database
- `pnpm run db:studio`: Open database studio UI
- `pnpm run check`: Run Oxlint and Oxfmt
- `pnpm run package:list`: List all packages in workspace

## Making a New Package

1. Make new folder in packages/
2. Add package.json (see other packages)
3. If it's a TS package, use the base config from the config package for your tsconfig.json (see db package for an example)
4. Run pnpm install in root
5. Run package:list to check that package is part of workspace


## iOS Info

### Development

The mobile app is entirely outside of Turborepo's control. Since there's no package.json in the ios/ folder, Turborepo doesn't know the app exists.
This is what we want, since Swift apps should be entirely under Xcode's control.

So, to develop the mobile app, **only use Xcode** and don't worry about Turborepo or build pipelines.

**Important**: Minimum Xcode 16.3 (Apollo iOS requires Swift 6.1).

Read the README in the apps/ios folder for more info on IOS-specific stuff.
