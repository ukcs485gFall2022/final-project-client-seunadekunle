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
        UIColor(red: 46, green: 59, blue: 61, alpha: 1)
    }

    var quaternaryCustomFill: UIColor {
        UIColor(red: 248, green: 109, blue: 54, alpha: 1)
    }

    var customBlue: UIColor {
        UIColor(red: 95, green: 119, blue: 130, alpha: 1)
    }
}
