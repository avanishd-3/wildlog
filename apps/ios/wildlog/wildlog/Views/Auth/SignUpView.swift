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
                Section(header: Text("Username")) {
                    TextField("User name", text: $name)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                }

                Section(header: Text("Email")) {
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
                    Button(action: {
                        Task {
                            do {
                                try await authManager.signup(email: email, password: password, userName: name)
                            } catch {
                                debugPrint("Sign up failed: \(error)")
                            }
                        }
                    }) {
                        Text("Create Account")
                    }
                    .tint(Color(.systemGreen))
                    .disabled(email.isEmpty || password.isEmpty || password.count < 8 || name.isEmpty || authManager.isLoading)

                    if authManager.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
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
