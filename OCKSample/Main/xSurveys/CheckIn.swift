//
//  CheckIn.swift
//  OCKSample
//
//  Created by Corey Baker on 11/11/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import CareKitStore
#if canImport(ResearchKit)
import ResearchKit
#endif

// todo: edit
struct CheckIn: Surveyable {
    static var surveyType: Survey {
        Survey.checkIn
    }

    static var formIdentifier: String {
        "\(Self.identifier()).form"
    }

    static var feelingItemIdentifier: String {
        "\(Self.identifier()).form.feeling"
    }

    static var dayTurnOutItemIdentifier: String {
        "\(Self.identifier()).form.dayTurnOut"
    }
}

enum SurveyAnswers {
    static let veryGood = "😊 Very Good"
    static let good = "🙂 Good"
    static let bad = "😒 Bad"
    static let veryBad = "😞 Very Bad"
    static let trackYes = "👍 Yes"
    static let trackNo = "👎 No"
    static let trackIDK = "🤔 IDK"
}

#if canImport(ResearchKit)
extension CheckIn {
    func createSurvey() -> ORKTask {

        let feelingTextChoices = [
            // swiftlint:disable:next line_length
            ORKTextChoice(text: SurveyAnswers.veryGood, value: SurveyAnswers.veryGood as NSSecureCoding & NSCopying & NSObjectProtocol),
            // swiftlint:disable:next line_length
            ORKTextChoice(text: SurveyAnswers.good, value: SurveyAnswers.good as NSSecureCoding & NSCopying & NSObjectProtocol),
            // swiftlint:disable:next line_length
            ORKTextChoice(text: SurveyAnswers.bad, value: SurveyAnswers.bad as NSSecureCoding & NSCopying & NSObjectProtocol),
            // swiftlint:disable:next line_length
            ORKTextChoice(text: SurveyAnswers.veryBad, value: SurveyAnswers.veryBad as NSSecureCoding & NSCopying & NSObjectProtocol)]

        // swiftlint:disable:next line_length
        let feelingAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: ORKChoiceAnswerStyle.singleChoice, textChoices: feelingTextChoices)

        let feelingItem = ORKFormItem(
            identifier: Self.feelingItemIdentifier,
            text: "How are you feeling right now?",
            answerFormat: feelingAnswerFormat
        )
        feelingItem.isOptional = false

        // swiftlint:disable:next line_length
        let dayTurnOutFormat = ORKAnswerFormat.booleanAnswerFormat(withYesString: SurveyAnswers.trackYes, noString: SurveyAnswers.trackNo)
        let dayTurnOutItem = ORKFormItem(
            identifier: Self.dayTurnOutItemIdentifier,
            text: "Are you enjoying Track?",
            answerFormat: dayTurnOutFormat
        )
        dayTurnOutItem.isOptional = false

        let formStep = ORKFormStep(
            identifier: Self.formIdentifier,
            title: "Check In with Track",
            text: "Please answer the following questions."
        )
        formStep.formItems = [feelingItem, dayTurnOutItem]
        formStep.isOptional = false

        let surveyTask = ORKOrderedTask(
            identifier: identifier(),
            steps: [formStep]
        )
        return surveyTask
    }

    func extractAnswers(_ result: ORKTaskResult) -> [OCKOutcomeValue]? {

        guard
            let response = result.results?
                .compactMap({ $0 as? ORKStepResult })
                .first(where: { $0.identifier == Self.formIdentifier }),

                let choiceResult = response
                .results?.compactMap({ $0 as? ORKChoiceQuestionResult }),

                let booleanResult = response
                .results?.compactMap({ $0 as? ORKBooleanQuestionResult }),

                let feelingAnswer = choiceResult
                .first(where: { $0.identifier == Self.feelingItemIdentifier })?
                .choiceAnswers?[0],

                let dayTurnOutAnswer = booleanResult
                .first(where: { $0.identifier == Self.dayTurnOutItemIdentifier })?
                .booleanAnswer

        else {
            assertionFailure("Failed to extract answers from check in survey!")
            return nil
        }

        // fills out the appropriate data type based on input
        var feelingValue: OCKOutcomeValue
        if let feelingValueStr = feelingAnswer as? String {
            feelingValue = OCKOutcomeValue(feelingValueStr)
        } else {
            feelingValue = OCKOutcomeValue("")
        }

        feelingValue.kind = Self.feelingItemIdentifier

        var dayTurnOutValue: OCKOutcomeValue
        if let dayTurnOutBool = dayTurnOutAnswer as? Bool {
            if dayTurnOutBool {
                dayTurnOutValue = OCKOutcomeValue(SurveyAnswers.trackYes)
            } else {
                dayTurnOutValue = OCKOutcomeValue(SurveyAnswers.trackNo)
            }
        } else {
            dayTurnOutValue = OCKOutcomeValue(SurveyAnswers.trackIDK)
        }

        dayTurnOutValue.kind = Self.dayTurnOutItemIdentifier

        return [feelingValue, dayTurnOutValue]
    }
}
#endif
