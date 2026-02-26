//
//  AuthenticationManager.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/26/26.
//

import Foundation
import Combine


/**
 * Requires iOS 17
 * Encapsulate sign-up, login, logout logic
 * Should be the only place where non-apollo request is made (everything but auth is in graphql)
 */
class AuthenticationManager: Observable {
    // MARK: Hardcoding auth url since not deploying
    var isAuthenticated = false
    var authenticatedError: String?
    var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    func signup(email: String, password: String, userName: String) async throws {
        isLoading = true
        authenticatedError = nil
        
        let url = URL(string: "https://localhost:3000/api/auth/sign-up/email")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try JSONSerialization.data(withJSONObject: ["email": email, "password": password, "name": userName], options: [])
        request.httpBody = jsonData
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            self.authenticatedError = URLError(.userAuthenticationRequired).localizedDescription
            throw URLError(.userAuthenticationRequired)
        }
        
        // Cookie stored automatically
        self.isAuthenticated = true
        self.isLoading = false
    }
    
    func login(email: String, password: String) async throws {
        isLoading = true
        authenticatedError = nil
        
        let url = URL(string: "https://localhost:3000/api/auth/sign-in/email")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try JSONSerialization.data(withJSONObject: ["email": email, "password": password], options: [])
        request.httpBody = jsonData
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            self.authenticatedError = URLError(.userAuthenticationRequired).localizedDescription
            throw URLError(.userAuthenticationRequired)
        }
        
        // Cookie stored automatically
        self.isAuthenticated = true
        self.isLoading = false
    }
    
    func logout() async throws {
        self.isAuthenticated = false
        
        let url = URL(string: "https://localhost:3000/api/auth/sign-out")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        _ = try await URLSession.shared.data(for: request)
        
        // Clear cookies only for our backend
        HTTPCookieStorage.shared.cookies?.forEach {
            guard $0.domain == "localhost:3000" else { return }
            HTTPCookieStorage.shared.deleteCookie($0)
        }
        
        // Reset Apollo cache
        try await Network.shared.apolloClient.clearCache()
    }
}
