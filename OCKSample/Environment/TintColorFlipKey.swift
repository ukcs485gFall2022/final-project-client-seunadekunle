//
//  TintColorFlipKey.swift
//  OCKSample
//
//  Created by Corey Baker on 9/26/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import SwiftUI

struct TintColorFlipKey: EnvironmentKey {
    static var defaultValue: UIColor {
        #if os(iOS)
        return ColorStyler.iconBlue
        #else
        return ColorStyler.iconBlue
        #endif
    }
}

extension EnvironmentValues {
    var tintColorFlip: UIColor {
        return ColorStyler.iconYellow
    }
}
