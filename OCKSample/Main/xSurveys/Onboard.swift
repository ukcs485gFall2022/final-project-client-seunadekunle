//  Onboarding.swift
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

struct Onboard: Surveyable {
    static var surveyType: Survey {
        Survey.onboard
    }
}

#if canImport(ResearchKit)
extension Onboard {
    func createSurvey() -> ORKTask {
        // The Welcome Instruction step.
        let welcomeInstructionStep = ORKInstructionStep(
            identifier: "\(identifier()).welcome"
        )

        welcomeInstructionStep.title = "Stay on Track with Track"
        welcomeInstructionStep.detailText = "Tap Next to begin"
        welcomeInstructionStep.image = UIImage(systemName: "checkmark")
        welcomeInstructionStep.imageContentMode = .scaleAspectFit

        // The Informed Consent Instruction step.
        let studyOverviewInstructionStep = ORKInstructionStep(
            identifier: "\(identifier()).overview"
        )

        studyOverviewInstructionStep.title = "Before You start"
        studyOverviewInstructionStep.iconImage = UIImage(systemName: "checkmark.circle")

        let heartStep = ORKLearnMoreInstructionStep(identifier: "\(identifier()).learnMoreStep")
        heartStep.image = UIImage(systemName: "heart.fill")
        heartStep.title = "Share Health Data"
        heartStep.text = "Your data will be protected according to regulations and Apple standards"
        let heartLearnMore = ORKLearnMoreItem(text: "Learn More", learnMoreInstructionStep: heartStep)
        let heartBodyItem = ORKBodyItem(
            text: "The study will ask you to share some of your health data.",
            detailText: nil,
            image: UIImage(systemName: "heart.fill"),
            learnMoreItem: heartLearnMore,
            bodyItemStyle: .image
        )

        let completeStep = ORKLearnMoreInstructionStep(identifier: "\(identifier()).completeStep")
        completeStep.image = UIImage(systemName: "checkmark.circle.fill")
        completeStep.title = "Complete Tasks"
        // swiftlint:disable:next line_length
        completeStep.text = "To provide us with more info, we will ask you to complete tasks over time. This shouldn't take more than a few minutes"
        let completeLearnMore = ORKLearnMoreItem(text: "Learn More", learnMoreInstructionStep: completeStep)

        let completeTasksBodyItem = ORKBodyItem(
            text: "You will be asked to complete various tasks over time",
            detailText: nil,
            image: UIImage(systemName: "checkmark.circle.fill"),
            learnMoreItem: completeLearnMore,
            bodyItemStyle: .image
        )

        let signatureBodyItem = ORKBodyItem(
            text: "Before joining, we will ask you to sign an informed consent document.",
            detailText: nil,
            image: UIImage(systemName: "signature"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )

        let secureDataBodyItem = ORKBodyItem(
            text: "Your data is kept private and secure.",
            detailText: nil,
            image: UIImage(systemName: "lock.fill"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )

        studyOverviewInstructionStep.bodyItems = [
            heartBodyItem,
            completeTasksBodyItem,
            signatureBodyItem,
            secureDataBodyItem
        ]

        // The Signature step (using WebView).
        let webViewStep = ORKWebViewStep(
            identifier: "\(identifier()).signatureCapture",
            html: informedConsentHTML
        )

        webViewStep.showSignatureAfterContent = true

        let healthKitTypesToWrite: Set<HKSampleType> = [
            .quantityType(forIdentifier: .bodyMassIndex)!,
            .quantityType(forIdentifier: .activeEnergyBurned)!,
            .workoutType(),
            .quantityType(forIdentifier: .dietarySugar)!,
            .quantityType(forIdentifier: .dietaryWater)!,
            .quantityType(forIdentifier: .dietaryProtein)!,
            .quantityType(forIdentifier: .flightsClimbed)!
        ]

        let healthKitTypesToRead: Set<HKObjectType> = [
            .characteristicType(forIdentifier: .dateOfBirth)!,
            .workoutType(),
            .quantityType(forIdentifier: .appleStandTime)!,
            .quantityType(forIdentifier: .appleExerciseTime)!,
            .quantityType(forIdentifier: .dietarySugar)!,
            .quantityType(forIdentifier: .dietaryWater)!,
            .quantityType(forIdentifier: .dietaryProtein)!,
            .quantityType(forIdentifier: .flightsClimbed)!
        ]

        let healthKitPermissionType = ORKHealthKitPermissionType(
            sampleTypesToWrite: healthKitTypesToWrite,
            objectTypesToRead: healthKitTypesToRead
        )

        let notificationsPermissionType = ORKNotificationPermissionType(
            authorizationOptions: [.alert, .badge, .sound]
        )

        let motionPermissionType = ORKMotionActivityPermissionType()

        let requestPermissionsStep = ORKRequestPermissionsStep(
            identifier: "\(identifier()).requestPermissionsStep",
            permissionTypes: [
                healthKitPermissionType,
                notificationsPermissionType,
                motionPermissionType
            ]
        )

        requestPermissionsStep.title = "Health Data Request"
        // swiftlint:disable:next line_length
        requestPermissionsStep.text = "Please review the health data types below and enable sharing to contribute to the study."

        // Completion Step
        let completionStep = ORKCompletionStep(
            identifier: "\(identifier()).completionStep"
        )

        completionStep.title = "Enrollment Complete"
        completionStep.text = "Thank you for participating. You are helping us to help you"

        let surveyTask = ORKOrderedTask(
            identifier: identifier(),
            steps: [
                welcomeInstructionStep,
                studyOverviewInstructionStep,
                webViewStep,
                requestPermissionsStep,
                completionStep
            ]
        )
        return surveyTask
    }

    func extractAnswers(_ result: ORKTaskResult) -> [CareKitStore.OCKOutcomeValue]? {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            Utility.requestHealthKitPermissions()
        }
        return [OCKOutcomeValue(Date())]
    }
}
#endif
