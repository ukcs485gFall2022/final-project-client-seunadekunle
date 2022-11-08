//
//  NewPlanViewModel.swift
//  OCKSample
//
//  Created by seun on 11/1/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
let uuid = UUID().uuidString

import SwiftUI
import CareKit
import CareKitUI
import CareKitStore
import HealthKit
import os.log

class NewPlanViewModel: ObservableObject {

    @Published var error: AppError?

    @Published public var title = ""
}
