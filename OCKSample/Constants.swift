//
//  Constants.swift
//  OCKSample
//
//  Created by Corey Baker on 11/27/20.
//  Copyright © 2020 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKit
import CareKitStore
import ParseSwift

/**
 Set to **true** to sync with ParseServer, *false** to sync with iOS/watchOS.
 */
let isSyncingWithCloud = true
/**
 Set to **true** to use WCSession to notify watchOS about updates, **false** to not notify.
 A change in watchOS 9 removes the ability to use Websockets on real Apple Watches,
 preventing auto updates from the Parse Server. See the link for
 details: https://developer.apple.com/forums/thread/715024
 */
let isSendingPushUpdatesToWatch = true

enum AppError: Error {
    case couldntCast
    case couldntBeUnwrapped
    case valueNotFoundInUserInfo
    case remoteClockIDNotAvailable
    case emptyTaskEvents
    case invalidIndexPath(_ indexPath: IndexPath)
    case noOutcomeValueForEvent(_ event: OCKAnyEvent, index: Int)
    case cannotMakeOutcomeFor(_ event: OCKAnyEvent)
    case parseError(_ error: ParseError)
    case error(_ error: Error)
    case errorString(_ string: String)
}

extension AppError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .couldntCast:
            return NSLocalizedString("OCKSampleError: Could not cast to required type.",
                                     comment: "Casting error")
        case .couldntBeUnwrapped:
            return NSLocalizedString("OCKSampleError: Could not unwrap a required type.",
                                     comment: "Unwrapping error")
        case .valueNotFoundInUserInfo:
            return NSLocalizedString("OCKSampleError: Could not find the required value in userInfo.",
                                     comment: "Value not found error")
        case .remoteClockIDNotAvailable:
            return NSLocalizedString("OCKSampleError: Could not get remote clock ID.",
                                     comment: "Value not available error")
        case .emptyTaskEvents: return "Task events is empty"
        case let .noOutcomeValueForEvent(event, index): return "Event has no outcome value at index \(index): \(event)"
        case .invalidIndexPath(let indexPath): return "Invalid index path \(indexPath)"
        case .cannotMakeOutcomeFor(let event): return "Cannot make outcome for event: \(event)"
        case .parseError(let error): return "\(error)"
        case .error(let error): return "\(error)"
        case .errorString(let string): return string
        }
    }
}

enum Constants {
    static let parseConfigFileName = "ParseCareKit"
    static let iOSParseCareStoreName = "iOSParseStore"
    static let iOSLocalCareStoreName = "iOSLocalStore"
    static let watchOSParseCareStoreName = "watchOSParseStore"
    static let watchOSLocalCareStoreName = "watchOSLocalStore"
    static let noCareStoreName = "none"
    static let parseUserSessionTokenKey = "requestParseSessionToken"
    static let requestSync = "requestSync"
    static let progressUpdate = "progressUpdate"
    static let finishedAskingForPermission = "finishedAskingForPermission"
    static let shouldRefreshView = "shouldRefreshView"
    static let userLoggedIn = "userLoggedIn"
    static let storeInitialized = "storeInitialized"
    static let userTypeKey = "userType"
    static let viewTypeKey = "ViewType"
    static let plotTypeKey = "PlotType"
    static let survey = "survey"
}

enum MainViewPath {
    case tabs
}

enum CarePlanID: String, CaseIterable, Identifiable {
    var id: String {
        return UUID().uuidString
    }

    case health // Add custom id's for your Care Plans, these are examples
    case checkIn
}

enum TaskID {
    static let doxylamine = "doxylamine"
    static let nausea = "nausea"
    static let stretch = "stretch"
    static let kegels = "kegels"
    static let steps = "steps"
    static let multistep = "multi-step"
    static let healthSugar = "healthSugar"
    static let defaultTask = "default"
    static let onboard = "onboard"
    static let repetition = "repetition"
    static let repetitionMood = "repetitionMood"
}

// For the different task views
enum PlotType: String, CaseIterable, Identifiable {

    case line
    case scatter
    case bar

    func getName(value: PlotType) -> String {

        switch value {
        case .line:
            return "Line Graph"
        case .scatter:
            return "Scatter Graph"
        case .bar:
            return "Bar Graph"
        }
    }

    var id: String {
        getName(value: self)
    }
}

enum HealthKitLinkages {
    static let countingSugar = OCKHealthKitLinkage(quantityIdentifier: .dietarySugar,
                                                   quantityType: .cumulative,
                                                   unit: .gram())
    static let waterIntake = OCKHealthKitLinkage(quantityIdentifier: .dietaryWater,
                                                 quantityType: .cumulative,
                                                 unit: .fluidOunceUS())
    static let protein = OCKHealthKitLinkage(quantityIdentifier: .dietaryProtein,
                                             quantityType: .cumulative,
                                             unit: .gram())
    static let flightsClimbed = OCKHealthKitLinkage(quantityIdentifier: .flightsClimbed,
                                                    quantityType: .cumulative,
                                                    unit: .count())
}
// For the different task views
enum ViewType: String, CaseIterable, Identifiable {

    case instructionsTaskView
    case simpleTaskView
    case checklist
    case buttonLog
    case gridTaskView
    case numericProgressTaskView
    case labeledValueTaskView
    case linkView
    case featuredContentView
    case survey
    case counter
    case logger

    // swiftlint:disable cyclomatic_complexity
    func getName(value: ViewType) -> String {
        switch value {
        case .instructionsTaskView:
            return "Instructions Task View"
        case .simpleTaskView:
            return "Simple Task View"
        case .checklist:
            return "Checklist"
        case .buttonLog:
            return "Button Log"
        case .gridTaskView:
            return "Grid Task View"
        case .numericProgressTaskView:
            return "Numeric Progress Task View"
        case .labeledValueTaskView:
            return "Labeled Task View"
        case .linkView:
            return "Link View"
        case .featuredContentView:
            return "Featured Content"
        case .survey:
            return "Survey"
        case .counter:
            return "Counter View"
        case .logger:
            return "Logger View"
        }
    }

    var id: String {
        getName(value: self)
    }
}

enum UserType: String, Codable {
    case patient = "Patient"
    case none = "None"

    // Return all types as an array, make sure to maintain order above
    func allTypesAsArray() -> [String] {
        return [UserType.patient.rawValue,
                UserType.none.rawValue]
    }
}

enum InstallationChannel: String {
    case global
}
