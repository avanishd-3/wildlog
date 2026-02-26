import SchemaBuilder from "@pothos/core";

import SimpleObjectsPlugin from "@pothos/plugin-simple-objects";
import ScopeAuthPlugin from "@pothos/plugin-scope-auth";

type Context = {
  user: {
    id: string;
  } | null;
};

/**
 * Configuring GraphQL schema builder
 * See: https://pothos-graphql.dev/docs/plugins/scope-auth for auth info
 * See: https://pothos-graphql.dev/docs/plugins/simple-objects for simple object tpes
 *
 * Definitions
 * Scope: Unit of authorization that can be used to authorize a request to resolve a field
 */
export const builder = new SchemaBuilder<{
  Context: Context;
  AuthScopes: {
    // Can add additional roles here (e.g., admin)
    loggedIn: boolean;
  };
}>({
  plugins: [ScopeAuthPlugin, SimpleObjectsPlugin], // IMPORTANT: ScopeAuthPlugin should be 1st (except for some exceptions, see docs)
  scopeAuth: {
    // Recommended when using subscriptions
    // when this is not set, auth checks are run when event is resolved rather than when the subscription is created
    authorizeOnSubscribe: true,
    treatErrorsAsUnauthorized: true, // Errors thrown in auth scope will be caught and treated as unathorized errors
    unauthorizedError: (_parent, _context, _info, _result) => new Error("Not authorized"),
    // scope initializer, create the scopes and scope loaders for each request
    authScopes: async (context) => ({
      loggedIn: !!context.user,
    }),
  },
});

// Create root Query and Mutation type
// Need this to prevent missing root type error

// You can only set authScope here if every query and mutation needs auth
// If not, individual queries & mutations cannot over-ride the default
builder.queryType({});
builder.mutationType({});
