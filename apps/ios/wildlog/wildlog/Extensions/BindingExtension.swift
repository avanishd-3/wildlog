//
//  BindingExtension.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/8/26.
//

// Extend binding so tab clicks can be detected
// Currently using this to detected clicks to map view
// But can also use this to detect if same tab is tapped (probably how YouTube does this to refresh content)
// See - https://stackoverflow.com/a/70529738

import SwiftUI

extension Binding {
    func onUpdate(_ closure: @escaping () -> Void) -> Binding<Value> {
        Binding(get: {
            wrappedValue
        }, set: { newValue in
            wrappedValue = newValue
            closure()
        })
    }
}
