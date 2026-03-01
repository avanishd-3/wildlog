//
//  SignUpView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/26/26.
//

import SwiftUI

struct SignUpView: View {
    @Environment(AuthenticationManager.self) private var authManager

    @State private var name = ""
    @State private var userName = "" // Name is actual name, username is for display
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("WildLog")
                .font(.largeTitle.bold())
                .foregroundColor(Color(.systemGreen))

            Form {
                Section(header: Text("Account Info")) {
                    TextField("Name", text: $name)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.words)
                    
                    TextField("User Name", text: $userName)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                    
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
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

                        Button {
                            showPassword.toggle()
                        } label: {
                            Image(systemName: showPassword ? "eye" : "eye.slash")
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
                    Button(action: {
                        Task {
                            do {
                                try await authManager.signup(email: email, password: password, name: name, userName: userName)
                            } catch {
                                debugPrint("Sign up failed: \(error)")
                            }
                        }
                    }) {
                        Text("Create Account")
                    }
                    .tint(Color(.systemGreen))
                    .disabled(email.isEmpty || !isValidEmail(email) || password.isEmpty || password.count < 8 || name.isEmpty || authManager.isLoading)

                    if authManager.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }
                
                Section {
                    NavigationLink(destination: LoginView().onAppear(perform: {authManager.resetUIState()})) // Reset any errors
                    {
                        
                        Text("Already have an account? Log in")
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    SignUpView().environment(AuthenticationManager())
}
