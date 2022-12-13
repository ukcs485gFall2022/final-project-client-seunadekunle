//
//  Survey.swift
//  OCKSample
//
//  Created by Corey Baker on 11/11/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitStore
#if canImport(ResearchKit)
import ResearchKit
#endif

enum Survey: String, CaseIterable, Identifiable {
    var id: Self { self }
    case onboard = "Onboard"
    case checkIn = "Check In"
    case motivate = "Motivate"

    func type() -> Surveyable {
        switch self {
        case .onboard:
            return Onboard()
        case .checkIn:
            return CheckIn()
        case .motivate:
            return Motivate()
        }
    }
}
