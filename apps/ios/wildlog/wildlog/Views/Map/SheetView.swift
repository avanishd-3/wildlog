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
    
    // Convert from park type enum to string in UI
    // This just makes it so NATIONAL -> National and so on
    func typeLabel(for type: ParkTypeEnum) -> String {
        type.rawValue.lowercased().capitalized(with: Locale.current)
    }

    // Convert from park cost enum to string in UI
    func costLabel(for cost: ParkCostFilterEnum) -> String {
        switch cost {
        case .free: return "Free"
        case .low: return "$"
        case .medium: return "$$"
        case .high: return "$$$"
        }
    }
    
    // Filter options
    let parkTypes = ParkTypeEnum.allCases.map { $0 }
    let parkCosts: [ParkCostFilterEnum] = [.free, .low, .medium, .high]
    
    // Selected values
    var selectedParkType: ParkTypeEnum? {
        filters?.type.value ?? .none
    }
    
    var selectedParkCost: ParkCostFilterEnum? {
        filters?.cost.value ?? .none
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                // I think disabling autocorrect makes it less annoying
                // to type rare words
                TextField("Search", text: Binding(
                    get: { filters?.search.unwrapped ?? "" },
                    set: { newValue in
                        if filters == nil { filters = ParkFiltersInput() }
                        filters?.search = newValue.isEmpty ? .none : .some(newValue)
                    }
                ))
                .task(id: filters?.search.unwrapped) {
                    if !(filters?.search.unwrapped == nil) {
                        
                        Task {
                            do {
                                // 300 ms debounce
                                debugPrint("In debounce task")
                                try await Task.sleep(nanoseconds: 300_000_000)
                                onFiltersChanged?()
                            } catch {
                                print("Error debouncing filters: \(error)")
                            }
                        }
                    }
                }
                .autocorrectionDisabled()
            }
            .modifier(TextFieldGrayBackgroundColor())
            
            // Filters
            VStack(alignment: .leading, spacing: 8) {
                FilterChips(
                    title: "Type",
                    options: parkTypes.map(typeLabel),
                    selected: selectedParkType.map(typeLabel),
                    onSelect: { label in
                        if filters == nil { filters = ParkFiltersInput() }
                        // Find the enum for selected toggle
                        if let enumCase = parkTypes.first(where: { typeLabel(for: $0) == label}) {
                            
                            // De-select if already selected toggle
                            if selectedParkType == enumCase {
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
                    options: parkCosts.map(costLabel),
                    selected: selectedParkCost.map(costLabel),
                    onSelect: { cost in
                        if filters == nil { filters = ParkFiltersInput() }
                        
                        // Find the enum for selected toggle
                        if let enumCase = parkCosts.first(where: { costLabel(for: $0) == cost}) {
                            
                            // De-select if already selected toggle
                            if selectedParkCost == enumCase {
                                filters?.cost = .none
                            } else {
                                filters?.cost = .some(GraphQLEnum(enumCase))
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

#Preview {
    SheetView(filters: .constant(ParkFiltersInput()))
}
