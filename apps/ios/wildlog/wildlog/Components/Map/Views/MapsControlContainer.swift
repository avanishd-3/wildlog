//
//  MapsControlContainer.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/6/26.
//

import Foundation
import UIKit

final class MapsControlContainer: UIVisualEffectView {
    // Set button colors and background stuff

    init() {
        super.init(effect: UIBlurEffect(style: .systemMaterial))
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 13
        clipsToBounds = true

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.masksToBounds = false
    }

    required init?(coder: NSCoder) {
        fatalError("We aren't using Storyboards")
    }
}
