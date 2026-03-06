//
//  LoginView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/26/26.
//

import SwiftUI

struct LoginView: View {
    @Environment(AuthenticationManager.self) private var authManager
    
    @State private var accountInfo = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Text("Welcome Back")
                .font(.title)
                .bold()
            
            Form {
                Section(header: Text("Account Info")) {
                    TextField("Email or username", text: $accountInfo)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                }
                
                Section(header: Text("Password")) {
                    SecureFieldWithEyeToggle(password: $password)
                }
                
                if let error = authManager.authenticatedError {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }

                Section {
                    Button("Log In") {
                        Task {
                            do {
                                let validEmail = isValidEmail(accountInfo)
                                
                                try await authManager.login(accountInfo: accountInfo, password: password, method: validEmail ? .email : .username)
                                
                            } catch {
                                debugPrint("Login failed: \(error)")
                            }
                        }
                    }
                    .disabled(accountInfo.isEmpty || password.isEmpty || authManager.isLoading)
                    .frame(maxWidth: .infinity)
                    
                    if authManager.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Spacer()
                        }
                    }
                }
                
                Section {
                    NavigationLink(destination: SignUpView().onAppear(perform: {authManager.resetUIState()})) // Don't want log-in error to still be visible
                    {
                        
                        Text("New account? Sign up")
                    }
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    LoginView().environment(AuthenticationManager())
}
