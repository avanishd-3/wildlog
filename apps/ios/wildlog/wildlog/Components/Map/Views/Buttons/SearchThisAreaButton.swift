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
        setTitle("Search This Area", for: .normal)
        setTitleColor(.white, for: .normal)
        backgroundColor = .systemBlue
        layer.cornerRadius = 10
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        translatesAutoresizingMaskIntoConstraints = false
        alpha = 0 // Hide by default
    }
}
