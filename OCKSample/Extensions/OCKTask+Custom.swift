//
//  OCKTask+Custom.swift
//  OCKSample
//
//  Created by seun on 11/21/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitStore

extension OCKTask {

    var survey: Survey {
        get {
            guard let surveyInfo = userInfo?[Constants.survey],
                  let surveyType = Survey(rawValue: surveyInfo) else {
                return .motivate // Default survey if none was saved
            }
            return surveyType // Saved survey type
        }
        set {
            if userInfo == nil {
                // Initialize userInfo with empty dictionary
                userInfo = .init()
            }
            // Set the new card type
            userInfo?[Constants.survey] = newValue.rawValue
        }
    }
}
