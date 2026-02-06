//
//  CustomUserTrackingButton.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/6/26.
//

// Had issues styling with regular button

import MapKit

final class CustomUserTrackingButton: UIControl {
    // Encapsulate logic for user button setup and image changes

    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = [.button]
        accessibilityLabel = "User Location"

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit

        addSubview(imageView)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 44),
            heightAnchor.constraint(equalToConstant: 44),

            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 20),
        ])
        
        // Default to none like Apple Maps
        imageView.image = UIImage(systemName: "location", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))
        accessibilityValue = "Off"
    }

    func update(for mode: MKUserTrackingMode) {
        let symbol: String
        let value: String

        switch mode {
        case .none:
            symbol = "location"
            value = "Off"
        case .follow:
            symbol = "location.fill"
            value = "Following"
        case .followWithHeading:
            symbol = "location.north.line.fill"
            value = "Following with heading"
        @unknown default:
            symbol = "location"
            value = "Off"
        }

        imageView.image = UIImage(
            systemName: symbol,
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 18,
                weight: .semibold
                )
        )

        accessibilityValue = value
    }
}
