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
- **Apollo client** - **_To set up_** (so iOS app can make graph ql queries)

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

## Server Setup

Because iOS apps can only make HTTPS requests (technically you can disable this, but your app will not be approved), the server is configured to **require** a certificate and key to run. If you try to run the server without these, the server will error.

To create a local SSL certificate, follow these instructions.

1. Install [mkcert](https://github.com/FiloSottile/mkcert)
2. Run `mkcert -install`
3. Run `mkcert -cert-file localhost.pem -key-file localhost-key.pem localhost 127.0.0.01 ::1`
4. Put localhost.pem and localhost-key.pem in apps/server

## Database Setup

This project uses PostgreSQL with Drizzle ORM and Neo4j.

1. Update your `apps/server/.env` file with your connection details.

2. Apply the schema to your PostgreSQL database:

```bash
pnpm run db:migrate
```

Then, run the development server:

```bash
pnpm run dev
```

The API is running at [http://localhost:3000](http://localhost:3000).

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

## iOS Info

### Development

The mobile app is entirely outside of Turborepo's control. Since there's no package.json in the ios/ folder, Turborepo doesn't know the app exists.
This is what we want, since Swift apps should be entirely under Xcode's control.

So, to develop the mobile app, **only use Xcode** and don't worry about Turborepo or build pipelines.

**Important**: Minimum Xcode 16.3 (Apollo iOS requires Swift 6.1).

Read the README in the ios folder for more info on IOS-specific stuff.
