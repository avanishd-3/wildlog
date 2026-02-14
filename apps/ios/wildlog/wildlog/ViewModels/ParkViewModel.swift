//
//  ParkViewModel.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/13/26.
//

import Foundation
import Observation
import WildLogAPI


// MARK: Demo to test Apollo Client, do not use as actual view model

@Observable // Requires iOS 17
final class ParkViewModel {
    var name: String = ""
    var description: String = ""
    var designation: GraphQLEnum<ParkDesignationEnum>?
    
    func fetchPark() {
        Task {
            do {
                let response = try await apolloClient.fetch(query: GetParkQuery())
                name = response.data?.getPark?.name ?? ""
                description = response.data?.getPark?.description ?? ""
                designation = response.data?.getPark?.designation ?? nil
            }
            catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}
