//
//  CustomFeaturedContentView.swift
//  OCKSample
//
//  Created by Corey Baker on 11/29/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//
import UIKit
import CareKit
import CareKitUI
import os.log

/// A simple subclass to take control of what CareKit already gives us.
class CustomFeaturedContentView: OCKFeaturedContentView {
    var url: URL?

    // Need to override so we can become delegate when the user taps on card
    override init(imageOverlayStyle: UIUserInterfaceStyle = .unspecified) {
        // See that this always calls the super
        super.init(imageOverlayStyle: imageOverlayStyle)

        // T0DO: 1 - Need to become a "delegate" so we know when view is tapped.
        self.delegate = self

        let gradientLayer = CAGradientLayer()
                gradientLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
                gradientLayer.colors = [UIColor.white.cgColor, UIColor.red.withAlphaComponent(0.5).cgColor]
                gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
                gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
                layer.addSublayer(gradientLayer)

    }

    // A convenience initializer to make it easier to use our custom featured content
    convenience init(url: String, imageOverlayStyle: UIUserInterfaceStyle = .unspecified) {
        // T0DO: 2 - Need to call the designated initializer
        self.init(imageOverlayStyle: imageOverlayStyle)
        // T0DO: 3 - Need to turn the url string into a real URL using URL(string: String)
        self.url = URL(string: url)

    }

}

/// Need to conform to delegate in order to be delegated to.
extension CustomFeaturedContentView: OCKFeaturedContentViewDelegate {

    func didTapView(_ view: OCKFeaturedContentView) {

        // When tapped open a URL.
        guard let url = url else {
            return
        }
        DispatchQueue.main.async {
            UIApplication.shared.open(url)
        }
    }
}
