//
//  DimensionStyler.swift
//  OCKSample
//
//  Created by seun on 10/11/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitUI
import UIKit
import SwiftUI

struct DimensionStyler: OCKDimensionStyler {

    // Changed style variable
    var lineWidth1: CGFloat { 2 }
    var imageHeight1: CGFloat { 50 }

    #if os(iOS)
    var separatorHeight: CGFloat { 0.5 / UIScreen.main.scale }
    var screenWidth: CGFloat { UIScreen.main.bounds.size.width }
    var screenHeight: CGFloat { UIScreen.main.bounds.size.height }
    var sidePadding: CGFloat { screenWidth / 15 }
    var splashIconSize: CGFloat { screenWidth / 2.5 }
    #endif
}
