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
        fatalError("We aren't using Storyboards")
    }

    func update(for pitch: CGFloat) {
        debugPrint("PitchButton: update(\(pitch))")
        animateTitleChange(to: pitch == 0 ? "3D" : "2D")
    }
    
    func animateTitleChange(to newTitle: String) {
        // Old title slides up and fades out and new title sides in from bottom
        // Make it very similar to Apple Maps
        
        // Make sure a title exists, which it should
        guard let label = titleLabel else {
            setTitle(newTitle, for: .normal)
            return
        }
        
        let snapshot = UILabel(frame: label.convert(label.bounds, to: self))
        snapshot.font = label.font
        snapshot.textColor = label.textColor
        snapshot.textAlignment = label.textAlignment
        snapshot.text = label.text
        snapshot.backgroundColor = .clear
        snapshot.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(snapshot)
        
        // Old text moving out
        UIView.animate(withDuration: 0.25) {
            snapshot.alpha = 0
            snapshot.frame.origin.y += snapshot.bounds.height
        } completion: { _ in
            snapshot.removeFromSuperview()
        }
        
        // New text moving in (hide until animation starts)
        setTitle(newTitle, for: .normal)
        label.alpha = 0
        
        UIView.animate(withDuration: 0.25, delay: 0.2) {
            label.frame.origin.y -= label.bounds.height
            label.alpha = 1
        }
        
        
        
    }
}
