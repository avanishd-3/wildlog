//
//  AuthenticationManager.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/26/26.
//

import Foundation
import Combine
import WildLogAPI


/**
 * Requires iOS 17
 * Encapsulate sign-up, login, logout logic
 * Should be the only place where non-apollo request is made (everything but auth is in graphql)
 */

@Observable
class AuthenticationManager {
    // MARK: Hardcoding auth url since not deploying
    var isAuthenticated = false
    var authenticatedError: String?
    var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private let baseURL = "https://localhost:3000"
    
    init() {
        configureURLSession()
    } // Init needs to be public for previews to work
    
    private func configureURLSession() { // Make sure cookies are sent in all requests
        URLSessionConfiguration.default.httpShouldSetCookies = true
        URLSessionConfiguration.default.httpCookieAcceptPolicy = .always
    }
    
    func checkAuthenticationStatus() async -> Bool {
        // Check cookie
        guard let cookies = HTTPCookieStorage.shared.cookies(for: URL(string: baseURL)!) else {
            debugPrint("No cookies found")
            self.isAuthenticated = false
            return false
        }
        
        debugPrint("Checked for cookie: \(cookies)")
        
        let hasValidCookie = cookies.contains { cookie in
            cookie.domain.contains("localhost") &&
            (cookie.expiresDate == nil || cookie.expiresDate! > Date())
        }
        
        debugPrint("Has valid cookie: \(hasValidCookie)")
        
        guard hasValidCookie else {
            self.isAuthenticated = false
            return false
        }
        
        // Verify cookie w/ backend
        do {
            let response = try await apolloClient.fetch(query: MeQuery())
            if let user = response.data?.me {
                debugPrint("User authenticated: \(user.id)")
                self.isAuthenticated = true
                return true
            }
            else {
                debugPrint("Has valid cookie, but user not found")
                self.isAuthenticated = false
                return false
            }
            
        } catch { // Consider yourself unauthenticated on any server error
            self.isAuthenticated = false
            return false
        }
        
        
    }
    
    func signup(email: String, password: String, name: String, userName: String) async throws {
        isLoading = true
        authenticatedError = nil
        
        let url = URL(string: "\(baseURL)/api/auth/sign-up/email")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // See: https://www.better-auth.com/docs/plugins/username#sign-up
        let jsonData = try JSONSerialization.data(withJSONObject: ["email": email, "password": password, "name": name, "username": userName], options: [])
        request.httpBody = jsonData
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            debugPrint("User sign up failed")
            self.authenticatedError = URLError(.userAuthenticationRequired).localizedDescription
            throw URLError(.userAuthenticationRequired)
        }
        
        debugPrint("Sign up response status: \(httpResponse.statusCode)")
        
        // Cookie stored automatically
        self.isAuthenticated = true
        self.isLoading = false
    }
    
    func login(email: String, password: String) async throws {
        isLoading = true
        authenticatedError = nil
        
        let url = URL(string: "\(baseURL)/api/auth/sign-in/email")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try JSONSerialization.data(withJSONObject: ["email": email, "password": password], options: [])
        request.httpBody = jsonData
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            debugPrint("User login failed")
            self.authenticatedError = URLError(.userAuthenticationRequired).localizedDescription
            throw URLError(.userAuthenticationRequired)
        }
        
        debugPrint("User login successful")
        
        // Cookie stored automatically
        self.isAuthenticated = true
        self.isLoading = false
    }
    
    func logout() async throws {
        self.isAuthenticated = false
        
        let url = URL(string: "\(baseURL)/api/auth/sign-out")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        _ = try await URLSession.shared.data(for: request)
        
        // Clear cookies only for our backend
        HTTPCookieStorage.shared.cookies?.forEach {
            guard $0.domain == "localhost" else { return }
            HTTPCookieStorage.shared.deleteCookie($0)
        }
        
        // Reset Apollo cache
        try await Network.shared.apolloClient.clearCache()
    }
}
