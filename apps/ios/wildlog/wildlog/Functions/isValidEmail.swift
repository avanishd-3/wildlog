//
//  isValidEmail.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/27/26.
//

import Foundation

func isValidEmail(_ email: String) -> Bool {
    // Follows format {name}@{end}.{ext}
    // ext must be at least 2 characters long
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    return email.range(of: emailRegex, options: .regularExpression, range: nil, locale: nil) != nil
}
