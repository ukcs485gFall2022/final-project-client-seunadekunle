//
//  Styler.swift
//  OCKSample
//
//  Created by Corey Baker on 10/16/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitUI

struct Styler: OCKStyler {
    var color: OCKColorStyler {
        ColorStyler()
    }
    var dimension: OCKDimensionStyler {
        DimensionStyler()
    }
    var animation: OCKAnimationStyler {
        AnimationStyler()
    }
    var appearance: OCKAppearanceStyler {
        AppearanceStyler()
    }
}
