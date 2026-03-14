//
//  RemoteImage.swift
//  WildLog
//
//  Created by Avanish Davuluri on 3/14/26.
//
// Store all the Kingfisher settings in 1 place
// This is just a default, views can use Kingfisher directly if they need more customization

import SwiftUI
import Kingfisher

struct RemoteImage: View {
    let url: URL
    
    var body: some View {
        KFImage.url(url)
            .backgroundDecode(true) // Avoid blocking main thread (helps prevent frame drops)
            .placeholder {
                Color(.systemGray)
            }
            .resizable()
            .loadTransition(.opacity, animation: .easeInOut(duration: 0.2)) // Use native SwiftUI transitions for better integration w/ the Swift UI animation system
            .onProgress {receivedSize, totalSize in }
            .onSuccess { result in }
            .onFailure { error in }
            .aspectRatio(contentMode: .fill) // So image is not stretched out
    }
}
