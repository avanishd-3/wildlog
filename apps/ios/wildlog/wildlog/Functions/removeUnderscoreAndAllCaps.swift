//
//  removeUnderscoreAndAllCaps.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/24/26.
//

import Foundation

/**
 * Map enum to more user-friendly string
 * Return string to prevent warning for not using the result
 */
func removeUnderscoreAndAllCaps(for string: String) -> String {
    string.replacingOccurrences(of: "_", with: " ").lowercased().capitalized(with: Locale.current)
}
