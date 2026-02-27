//
//  AuthContainerView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/26/26.
//

import SwiftUI

// Show log-in by default but give them link to sign up
struct AuthContainerView: View {
    @Environment(AuthenticationManager.self) private var authManager
    
    // Set logged in to true on sign in
    var onSignIn: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            LoginView(onSignIn: onSignIn).toolbar(.hidden)
        }
    }
}

#Preview {
    AuthContainerView().environment(AuthenticationManager())
}
