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
    #endif
}
