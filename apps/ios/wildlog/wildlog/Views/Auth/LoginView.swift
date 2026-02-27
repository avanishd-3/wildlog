//
//  LoginView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/26/26.
//

import SwiftUI

struct LoginView: View {
    @Environment(AuthenticationManager.self) private var authManager
    
    @State private var email = ""
    @State private var password = ""
    
    @State private var showPassword = false // Toggle password visibility
    
    var body : some View {
        VStack(spacing: 16) {
            Spacer()
            
            Text("Welcome Back")
                .font(.title)
                .bold()
            
            Form {
                Section(header: Text("Login")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                    
                }
                
                HStack {
                    if showPassword {
                        TextField("Password", text: $password)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                    } else {
                        SecureField("Password", text: $password)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                    }
                    
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundStyle(Color(.systemGray))
                    }
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
                                try await authManager.login(email: email, password: password)
                            } catch {
                                // TODO: Handle log-in errors
                            }
                        }
                    }
                    .disabled(email.isEmpty || password.isEmpty || authManager.isLoading)
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
                
                // Sign-up link
                NavigationLink(destination: SignUpView()) {
                    Text("New account? Sign up")
                        .foregroundStyle(Color(.systemBlue))
                }
            }
        }
    }
}

#Preview {
    LoginView().environment(AuthenticationManager())
}
