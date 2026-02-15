//
//  SheetView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/5/26.
//

// See: https://www.polpiella.dev/mapkit-and-swiftui-searchable-map
// It's not exactly this because some stuff is deprecated but it's close

import SwiftUI
import MapKit
import WildLogAPI

struct SheetView: View {
    
    @Binding var filters: ParkFiltersInput?
    var onFiltersChanged: (() -> Void)? = nil // Notify parent of filter change
    
    // Convert from park typ eenum to string in UI
    // This just makes it so NATIONAL -> National and so on
    func typeLabel(for type: ParkTypeEnum) -> String {
        type.rawValue.lowercased().capitalized(with: Locale.current)
    }

    // Convert from park cost enum to string in UI
    // Free -> Free
    // Low -> $
    // Medium -> $$
    // High -> $$$$
    func costLabel(for cost: ParkCostFilterEnum) -> String {
        switch cost {
        case .free: return "Free"
        case .low: return "$"
        case .medium: return "$$"
        case .high: return "$$$"
        }
    }

    // Selected type as UI label
    var selectedTypeLabel: String? {
        if let typeEnum = filters?.type.value {
            return typeLabel(for: typeEnum!)
        }
        return nil
    }
    
    // Selected cost as UI label
    var selectedCostLabel: String? {
        if let costEnum = filters?.cost.value {
            return costLabel(for: costEnum!)
        }
        return nil
    }
    

    // Filter options
    let parkTypes = ParkTypeEnum.allCases.map { value in
        // Uppercase first letter of word
        value.rawValue.lowercased().capitalized(with: Locale.current)
    }
    let parkCosts = ["Free", "$", "$$", "$$$"]
    
    // Safely unwrap the selected type
    var selectedType: String? {
        if let typeEnum = filters?.type, case let .some(enumValue) = typeEnum {
            return enumValue.value?.rawValue
        }
        return nil
    }

    // Safely unwrap the selected cost
    var selectedCost: String? {
        if let costEnum = filters?.cost, case let .some(enumValue) = costEnum {
            return enumValue.value?.rawValue
        }
        return nil
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                // I think disabling autocorrect makes it less annoying
                // to type rare words
                TextField("Search", text: Binding(
                    get: {
                        if let search = filters?.search, case let .some(value) = search {
                            return value
                        }
                        return ""
                    },
                    set: { newValue in
                        if filters == nil { filters = ParkFiltersInput() }
                        filters?.search = newValue.isEmpty ? .none : .some(newValue)
                        // TODO: Add debounce on search
                        onFiltersChanged?()
                    }
                ))
                .autocorrectionDisabled()
            }
            .modifier(TextFieldGrayBackgroundColor())
            
            // Filters
            VStack(alignment: .leading, spacing: 8) {
                FilterChips(
                    title: "Type",
                    options: parkTypes,
                    selected: selectedTypeLabel,
                    onSelect: { type in
                        if filters == nil { filters = ParkFiltersInput() }
                        // Find the enum case for the selected type
                        if let enumCase = ParkTypeEnum.allCases.first(where: { typeLabel(for: $0) == type}) {
                            if selectedType == type {
                                filters?.type = .none
                            } else {
                                filters?.type = .some(GraphQLEnum(enumCase))
                            }
                        } else {
                            filters?.type = .none
                        }
                        onFiltersChanged?()
                    }
                )
                
                FilterChips(
                    title: "Cost",
                    options: parkCosts,
                    selected: selectedCostLabel,
                    onSelect: { cost in
                        if filters == nil { filters = ParkFiltersInput() }
                        // Map UI label to enum value
                        let enumValue: ParkCostFilterEnum? = switch cost {
                            case "Free": .free
                            case "$": .low
                            case "$$": .medium
                            case "$$$": .high
                            default: nil
                        }
                        
                        if let enumValue {
                            if selectedCost == cost {
                                filters?.cost = .none
                            } else {
                                filters?.cost = .some(GraphQLEnum(enumValue))
                            }
                        } else {
                            filters?.cost = .none
                        }
                        onFiltersChanged?()
                    }
                )
                
                Spacer()
            }
            .padding()
            // Do not allow user to dismiss sheet
            // Since Swift UI maintains views, they cannot bring it back up
            // Have a back button in the map instead
            // I think this is fine UX, but maybe having search as a tab is not the best option
            // TODO: See if memory is an issue w/ keeping the map and how to handle it
            .interactiveDismissDisabled(true)
            .presentationDetents([.height(200), .large]) // Sheet view will auto-resize when user types in search
            .presentationBackground(.regularMaterial) // Apple Maps-like blur for sheet
            // User can interact with map view behind sheet
            .presentationBackgroundInteraction(.enabled(upThrough: .large))
        }
    }
}

struct TextFieldGrayBackgroundColor: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8.0, style: .continuous))
            .foregroundColor(.primary)
    }
}

//#Preview {
//    SheetView(search: Binding<String("hello")>)
//}
