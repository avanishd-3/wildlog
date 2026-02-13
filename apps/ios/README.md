# GraphQL

Using the [Apollo iOS client] to make API requests. Unlike the code-first approach of Pothos, Apollo is schema-first. This means the schema files located in ios/WildLog/graphql are the **source of truth** for the iOS app.

The configuration for Apollo iOS is apollo-codegen-config.json.


If you are modifying the server schema, you can run `./apollo-ios-cli fetch-schema` to get the new GraphQL schema. This will be automatically put in ios/WildLog/graphql/schema.graphqls.

If you do this, you still need to put the queries in their own files (since Apollo requires operations). Currently, I just have it done manually (see park.graphql for an example), but perhaps there is a way to automate this.

Now that the schema has been fetched, run `./apollo-ios-cli generate` to create the Swift classes based on the above. Once you do this, you should be able to call the queries from Swift UI by importing the WildLogAPI package.

**Important**: The schema should have a .graphqls extension, while the operations have a .graphql extension. Remember this if you are looking at modifying the codegen configuration.

# Certification
iOS does not allow making HTTP requests without HTTPS & valid SSL certificates. To create a local SSL certificate, follow these instructions.
Simulator instructions from [here](https://stackoverflow.com/questions/2219707/adding-a-self-signed-certificate-to-iphone-simulator).

1. Install [mkcert](https://github.com/FiloSottile/mkcert)
2. Run `mkcert -install`
3. Run `mkcert -cert-file localhost.pem -key-file localhost-key.pem localhost 127.0.0.01 ::1`
4. Put localhost.pem and localhost-key.pem in apps/server
5. Go to Xcode and launch the simulator
6. In the terminal, run `mkcert -CAROOT`. This will tell you where the mkcert root certificates are.
7. In finder, navigate to the folder outputted in step 6 (I got the format /Users/username/Library/Application Support/mkcert), but your's may be different.
8. Drag and drop rootCA.pem onto the simulator homescreen.
9. On the simulator, go to Settings -> General -> About -> Certificate Trust Settings and verify that you see the certificate there.