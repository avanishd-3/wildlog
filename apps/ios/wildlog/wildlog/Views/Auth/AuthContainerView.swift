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

    var body: some View {
        NavigationStack {
            LoginView().toolbar(.hidden)
        }
    }
}

#Preview {
    AuthContainerView().environment(AuthenticationManager())
}
