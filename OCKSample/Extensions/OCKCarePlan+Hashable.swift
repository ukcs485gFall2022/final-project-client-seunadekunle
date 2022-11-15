//
//  OCKCarePlan+Hashable.swift
//  OCKSample
//
//  Created by seun on 11/15/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitStore

 // Needed to use OCKCarePlan in a Picker.
 // Simple conformance to hashable protocol.
 extension OCKCarePlan: Hashable {
     public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
 }
