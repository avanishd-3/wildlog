//
//  SecureFieldWithEyeToggle.swift
//  WildLog
//
//  Created by Avanish Davuluri on 3/5/26.
//

import Foundation
import SwiftUI

struct SecureFieldWithEyeToggle: View {
    @Binding var password: String
    @State var showPassword: Bool = false
    
    var body: some View {
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
                Image(systemName: showPassword ? "eye" : "eye.slash")
                    .foregroundStyle(Color(.systemGray))
            }
        }
    }
}

#Preview {
    SecureFieldWithEyeToggle(password: .constant("test"))
}
