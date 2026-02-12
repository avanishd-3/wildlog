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
pnpm run db:migrate
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

#### Git
Comitting in Xcode **will not work**, because it cannot run the husky linter. So, review the changes in Xcode and commit in the termianl or somewhere else.
Switching branches in Xcode will work, though.

### Why is there a WildLog/WildLog

The first WildLog is the workspace, where tests and dependencies live. The second WildLog is the app itself. Technically, the workspace can contain multiple apps and frameworks, but we will not be doing that,
which is why the workspace is also called WildLog.

### App Settings

These are all configured in Xcode by clicking on the project folder (which is ios/WildLog) in Xcode. You may come across documentation online that references Info.plist, but Apple removed it, and the
only way to update app stuff and build settings is by using this UI. For phone capabilities that need authorization, like HealthKit, follow the Apple documentation to learn how to add them.

### SwiftUI vs UIKit

SwiftUI is an abstraction over UIKit and is much less verbose. Unfortunately, if you want a lot of customization and control over the UI, you need to go back to using a UIKit component.

To integrate the UI Kit View into the Swift UI View hierarchy, you need to use a View Representable, which is why all our UIKit stuff has one.

SwiftUI is declarative (like React). You write what the UI should look like and it handles updates automatically.
UIKit is imperative. You define how the UI behaves and need to manage updates manually (which is where the boilerplate comes from).

### Icons

The WildLog icon was created in Icon Composer, so if you want to make changes, open it in Icon Composer and **look at all modes** (even mono and tinted).

However, .icon files made by Icon Composer are not supported unless you are using iOS 26. I don't think this is mentioned in Apple's documentation and it took me a while to figure this out.
So, if you want to update the icon, you need to go to WildLog/Assets.xcassets and update the images in WildLog.appiconset. In Xcode, this is clicking Assets and then clicking WildLog.

The easiest way to get new images is to export the files from Icon Composer. When exporting, select Platform>iOS and Appearance>All. Don't touch the size and light angle unless you know what you're doing.
Once you have the images, you can drag and drop them in the Xcode grid for the app icon.

**Important**: The app icon must have the same name as the specified in General>App Icons and Launch Screen or the build will fail. I have set it to WildLog (the app name). I don't think this needs to be changed.

I've left the .icon file in the project. It serves as the ***single source of truth*** for what the icon should look like in all conditions. If you update the icon, change the file after you're done updating WildLog.appiconset.


### Color

When doing anything with Color, **always** use Color(.systemColor). This is much more accessible than using Color.green, for example.
People can re-bind the colors in their phones to different ones, and they also change with light/dark mode. For example, dark mode uses a darker shade of green.

There's a WWDC video on this somewhere. Watch it if you need more info.

### Navigation

**Do not** use NavigationLink with destination. This creates the view with the navigation link, instead of when the user clicks into that view. This is super inefficient when there's a lot of NavigationLinks present in a view.

### Maps

Unfortunately, map stuff doesn't work in the preview. Use the simulator instead.

### Custom UI components

See the README in the Components folder for when to use the custom components. For most use cases, you shouldn't need them.

### Other

**Do not** use private APIs. Apple rejects apps for doing this, and it's not good practice. Depcreated stuff is bad, but at least it's still valid for a while.

The minimum deployment is iOS 18, which is about 88-90% of all iOS users. So, we might be able to downgrade the minimum deployment. However, Swift Data may be buggy with iOS 17, so if we have issues with it, we shouldn't worry about reducing the minimum deployument.

I set the App categpry for social networking. but category only matters when publishing to the App store, so this shouldn't be too much of a concern.


