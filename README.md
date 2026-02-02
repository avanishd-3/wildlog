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

## Database Setup

This project uses PostgreSQL with Drizzle ORM and Neo4j.

1. Update your `apps/server/.env` file with your connection details.

2. Apply the schema to your PostgreSQL database:

```bash
pnpm run db:push
```

Then, run the development server:

```bash
pnpm run dev
```

The API is running at [http://localhost:3000](http://localhost:3000).

## Git Hooks and Formatting

- Initialize hooks: `pnpm run prepare`
- Format and lint fix: `pnpm run check`

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
- `pnpm run dev:web`: Start only the web application
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

In the Xcode top middle panel, to the left of the simulator settings, there is a button that says WildLog. If you click that, you can edit the schemes. Schemes configure how you perform your actions (e.g., build, run, test, etc...). Usually, there's one for each app (e.g., one iOS scheme and one watch scheme), but we're only doing an iOS app, so we only have 1 scheme for now. Schemes are where you set environment variables, among other things.

### Why is there a WildLog/WildLog

The first WildLog is the workspace, where tests and dependencies live. The second WildLog is the app itself. Technically, the workspace can contain multiple apps and frameworks, but we will not be doing that,
which is why the workspace is also called WildLog.

### App Settings

These are all configured in Xcode by clicking on the project folder (which is ios/WildLog) in Xcode. You may come across documentation online that references Info.plist, but Apple removed it, and the
only way to update app stuff and build settings is by using this UI. For phone capabilities that need authorization, like HealthKit, follow the Apple documentation to learn how to add them.

### Icons

The WildLog icon was created in Icon Composer, so if you want to make changes, open it in Icon Composer and **look at all modes** (even mono and tinted).

However, .icon files made by Icon Composer are not supported unless you are using iOS 26. I don't think this is mentioned in Apple's documentation and it took me a while to figure this out.
So, if you want to update the icon, you need to go to WildLog/Assets.xcassets and update the images in WildLog.appiconset. In Xcode, this is clicking Assets and then clicking WildLog.

The easiest way to get new images is to export the files from Icon Composer. When exporting, select Platform>iOS and Appearance>All. Don't touch the size and light angle unless you know what you're doing.
Once you have the images, you can drag and drop them in the Xcode grid for the app icon.

**Important**: The app icon must have the same name as the specified in General>App Icons and Launch Screen or the build will fail. I have set it to WildLog (the app name). I don't think this needs to be changed.

I've left the .icon file in the project. It serves as the ***single source of truth*** for what the icon should look like in all conditions. If you update the icon, change the file after you're done updating WildLog.appiconset.

### Other

The minimum deployment is iOS 18.2, as most people have not updated to iOS 26. I think for the Swift UI nice stuff, we only need iOS 17 at a minimum, but having it higher isn't that bad. Once we're done, we can set the target down if we can. If there's something that iOS 26 makes nicer, which I doubt, we can think about bumping up the minimum deployment. But most of the Swift UI nice stuff is in iOS 17. I think Swift Data might be buggy on iOS 17, so if we use that a lot, we shouldn't downgrade the minimum deployment.

I set the App categpry for social networking. but category only matters when publishing to the App store, so this shouldn't be too much of a concern.


