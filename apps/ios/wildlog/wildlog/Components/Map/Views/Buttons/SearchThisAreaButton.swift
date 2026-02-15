//
//  SearchThisAreaButton.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/14/26.
//

import Foundation
import UIKit

final class SearchThisAreaButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        // Make button look like Apple Maps
        
        // iOS 15 new button API: https://sarunw.com/posts/new-way-to-style-uibutton-in-ios15/#more-customization
        
        var container = AttributeContainer()
        container.font = UIFont.preferredFont(forTextStyle: .headline)
        
        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString("Search here", attributes: container)
        config.baseBackgroundColor = .tertiarySystemBackground
        config.baseForegroundColor = .systemBlue
        config.buttonSize = .large
        configuration?.background.cornerRadius = 16
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16) // Distance from text to border
        
        self.configuration = config
        
        
        // These are not covered by the iOS 15 new button API above
        translatesAutoresizingMaskIntoConstraints = false // Button invisible w/o this
        alpha = 0 // Hide by default
    }
}
