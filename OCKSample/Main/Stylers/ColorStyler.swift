//
//  ColorStyler.swift
//  OCKSample
//
//  Created by Corey Baker on 10/16/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitUI
import UIKit
import SwiftUI

struct ColorStyler: OCKColorStyler {
    #if os(iOS)
        var label: UIColor {
            FontColorKey.defaultValue
        }
        var tertiaryLabel: UIColor {
            TintColorKey.defaultValue
        }
    #endif

    // Changed style variables
    var customBackground: UIColor {
        UIColor(red: 0.98, green: 0.98, blue: 0.96, alpha: 1.00)
    }

    var quaternaryCustomFill: UIColor {
        UIColor(red: 0.97, green: 0.43, blue: 0.21, alpha: 1.00)
    }

    var customBlue: UIColor {
        ColorStyler.iconBlue
    }

    static var iconRed: UIColor {
        return UIColor(red: 0.86, green: 0.17, blue: 0.22, alpha: 1.00)
    }

    static var iconYellow: UIColor {
        return UIColor(red: 0.95, green: 0.65, blue: 0.07, alpha: 1.00)
    }

    static var iconBlue: UIColor {
        return UIColor(red: 0.16, green: 0.20, blue: 0.36, alpha: 1.00)
    }

    public static func convertToColor(color: UIColor) -> Color {
        return Color(uiColor: color)
    }

}
