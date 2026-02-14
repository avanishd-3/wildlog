
# Git

Comitting in Xcode **will not work**, because it cannot run the husky linter. So, review the changes in Xcode and commit in the termianl or somewhere else.
Switching branches in Xcode will work, though.

# App-Specific Stuff

This section is what you need to know for the purely iOS stuff (no backend integration).

It mainly goes over some Xcode things, talks about Swift UI vs UI Kit, and has some best practices for Swift UI and the custom UI components.

## Why is there a WildLog/WildLog

The first WildLog is the workspace, where tests and dependencies live. The second WildLog is the app itself. Technically, the workspace can contain multiple apps and frameworks, but we will not be doing that,
which is why the workspace is also called WildLog.

## Schemes

In the Xcode top middle panel, to the left of the simulator settings, there is a button that says WildLog. If you click that, you can edit the schemes. Schemes configure how you perform your actions (e.g., build, run, test, etc...). Usually, there's one for each app (e.g., one iOS scheme and one watch scheme), but we're only doing an iOS app, so we only have 1 scheme for now. Schemes are where you set environment variables, among other things.

## App Settings

These are all configured in Xcode by clicking on the project folder (which is ios/WildLog) in Xcode. You may come across documentation online that references Info.plist, but Apple removed it, and the
only way to update app stuff and build settings is by using this UI. For phone capabilities that need authorization, like HealthKit, follow the Apple documentation to learn how to add them.

## SwiftUI vs UIKit

SwiftUI is an abstraction over UIKit and is much less verbose. Unfortunately, if you want a lot of customization and control over the UI, you need to go back to using a UIKit component.

To integrate the UI Kit View into the Swift UI View hierarchy, you need to use a View Representable, which is why all our UIKit stuff has one.

SwiftUI is declarative (like React). You write what the UI should look like and it handles updates automatically.
UIKit is imperative. You define how the UI behaves and need to manage updates manually (which is where the boilerplate comes from).

## Icons

The WildLog icon was created in Icon Composer, so if you want to make changes, open it in Icon Composer and **look at all modes** (even mono and tinted).

However, .icon files made by Icon Composer are not supported unless you are using iOS 26. I don't think this is mentioned in Apple's documentation and it took me a while to figure this out.
So, if you want to update the icon, you need to go to WildLog/Assets.xcassets and update the images in WildLog.appiconset. In Xcode, this is clicking Assets and then clicking WildLog.

The easiest way to get new images is to export the files from Icon Composer. When exporting, select Platform>iOS and Appearance>All. Don't touch the size and light angle unless you know what you're doing.
Once you have the images, you can drag and drop them in the Xcode grid for the app icon.

**Important**: The app icon must have the same name as the specified in General>App Icons and Launch Screen or the build will fail. I have set it to WildLog (the app name). I don't think this needs to be changed.

I've left the .icon file in the project. It serves as the **_single source of truth_** for what the icon should look like in all conditions. If you update the icon, change the file after you're done updating WildLog.appiconset.

## Color

When doing anything with Color, **always** use Color(.systemColor). This is much more accessible than using Color.green, for example.
People can re-bind the colors in their phones to different ones, and they also change with light/dark mode. For example, dark mode uses a darker shade of green.

There's a WWDC video on this somewhere. Watch it if you need more info.

# Navigation

**Do not** use NavigationLink with destination. This creates the view with the navigation link, instead of when the user clicks into that view. This is super inefficient when there's a lot of NavigationLinks present in a view.

# Maps

Unfortunately, map stuff doesn't work in the preview. Use the simulator instead.

# Custom UI components

See the README in the Components folder for when to use the custom components. For most use cases, you shouldn't need them.

# Other

**Do not** use private APIs. Apple rejects apps for doing this, and it's not good practice. Depcreated stuff is bad, but at least it's still valid for a while.

The minimum deployment is iOS 18, which is about 88-90% of all iOS users. So, we might be able to downgrade the minimum deployment. However, Swift Data may be buggy with iOS 17, so if we have issues with it, we shouldn't worry about reducing the minimum deployument.

I set the App categpry for social networking. but category only matters when publishing to the App store, so this shouldn't be too much of a concern.

# Integrating with the Backend

## GraphQL

Using the [Apollo iOS client] to make API requests. Unlike the code-first approach of Pothos, Apollo is schema-first. This means the schema files located in ios/WildLog/graphql are the **source of truth** for the iOS app.

The configuration for Apollo iOS is apollo-codegen-config.json.

If you are modifying the server schema, you can run `./apollo-ios-cli fetch-schema` to get the new GraphQL schema. This will be automatically put in ios/WildLog/graphql/schema.graphqls.

Once you do this, you still need to write the queries/mutations you plan to use for the app (see park.graphql for an example).

Now that the schema has been fetched and new queries/mutations have been written, run `./apollo-ios-cli generate` to create the Swift classes for them. Once you do this, you should be able to call the queries from Swift UI by importing the WildLogAPI package.

**Important**: The schema should have a .graphqls extension, while the operations have a .graphql extension. Remember this if you are looking at modifying the codegen configuration.

## Certification

**Important**: You need to do this or the client will not be able to make API requests. because iOS does not allow making HTTP requests without HTTPS & valid SSL certificates. 
Simulator instructions from [here](https://stackoverflow.com/questions/2219707/adding-a-self-signed-certificate-to-iphone-simulator).

Make sure you have followed the certificate instructions in the main README first and verify the server can run without issues.

Once you have done that, you can add the root certificate to the simulator by following these instructions.

1. Go to Xcode and launch the simulator
2. In the terminal, run `mkcert -CAROOT`. This will tell you where the mkcert root certificates are.
3. In finder, navigate to the folder outputted in step 6 (I got the format /Users/username/Library/Application Support/mkcert), but your's may be different.
4. Drag and drop rootCA.pem onto the simulator homescreen.
5. On the simulator, go to Settings -> General -> About -> Certificate Trust Settings and verify that you see the certificate there.
6. On the simulator, re-open the app and go to the Lists tab. If you click the fetch park info button, you should see the text Yellowstone National Park.

Keep in mind that this only works in the simulator. I don't think you can add a certificate to the preview, but the preview isn't meant for trying API requests anyways.