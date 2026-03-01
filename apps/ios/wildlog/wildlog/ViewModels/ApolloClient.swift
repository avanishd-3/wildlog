//
//  ApolloClient.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/13/26.
//

import Foundation
import Apollo
import ApolloAPI

// MARK: Auth info here -> https://www.apollographql.com/docs/ios/tutorial/tutorial-authenticate-operations

struct AuthorizationInterceptor: HTTPInterceptor {
    func intercept(request: URLRequest, next: NextHTTPInterceptorFunction) async throws -> HTTPResponse {
        // No-op, since we're using cookies
        // URLSession handles cookies, if using tokens this would need to do something
        return try await next(request)
    }
}

struct NetworkInterceptorProvider: InterceptorProvider {
    func httpInterceptors<Operation: GraphQLOperation>(for operation: Operation) -> [any HTTPInterceptor] {
        return [AuthorizationInterceptor()] + DefaultInterceptorProvider.shared.httpInterceptors(for: operation)
    }
}

final class Network {
    static let shared = Network()
    let apolloClient: ApolloClient
    
    private init() {
        // Setup Apollo client
        
        let cache = InMemoryNormalizedCache()
        let store = ApolloStore(cache: cache)

        // MARK: Hard-coding server URL since we're not deploying
        let url = URL(string: "https://localhost:3000/graphql")!


        let networkTransport = RequestChainNetworkTransport(
            urlSession: URLSession.shared,
            interceptorProvider: NetworkInterceptorProvider(),
            store: store,
            endpointURL: url
        )

        self.apolloClient = ApolloClient(networkTransport: networkTransport, store: store)
    }
}


let apolloClient = Network.shared.apolloClient
