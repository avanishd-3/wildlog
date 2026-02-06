//
//  CustomPitchButton.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/6/26.
//

import UIKit

final class CustomPitchButton: UIButton {
    // Setup and text change for pitch toggle

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        setTitleColor(.label, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        setTitle("3D", for: .normal) // Set initial title based on actual pitch
        backgroundColor = .clear
        accessibilityLabel = "Toggle 3D"

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 44),
            heightAnchor.constraint(equalToConstant: 44),
        ])

    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func update(for pitch: CGFloat) {
        debugPrint("PitchButton: update(\(pitch))")
        setTitle(pitch == 0 ? "3D" : "2D", for: .normal)
    }
}
