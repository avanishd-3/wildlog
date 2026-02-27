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
    @State private var showPassword = false
    
    func isEmailValid(_ email: String) -> Bool {
        // Follows format {name}@{end}.{ext}
        // ext must be at least 2 characters long
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return email.range(of: emailRegex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
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
                                let validEmail = isEmailValid(accountInfo)
                                
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
                    NavigationLink(destination: SignUpView()) {
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
