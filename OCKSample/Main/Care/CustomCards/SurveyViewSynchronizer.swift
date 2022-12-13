//
//  SurveyViewSynchronizer.swift
//  OCKSample
//
//  Created by Corey Baker on 11/11/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import CareKit
import CareKitStore
import CareKitUI
import ResearchKit
import UIKit
import os.log

final class SurveyViewSynchronizer: OCKSurveyTaskViewSynchronizer {

    override func updateView(
        _ view: OCKInstructionsTaskView,
        context: OCKSynchronizationContext<OCKTaskEvents>) {

            super.updateView(view, context: context)

            if let event = context.viewModel.first?.first, event.outcome != nil {

                // first retrieve the task
                guard let surveyTask = event.task as? OCKTask else {
                    return
                }

                if let title = surveyTask.title {
                    let header = OCKHeaderView()
                    header.titleLabel.text = title

                    view.insertSubview(header, at: 0)
                }

                // displays custom info based on the survey type
                if surveyTask.userInfo?[Constants.viewTypeKey] == ViewType.survey.rawValue {
                    // swiftlint:disable:next line_length
                    let identifier = surveyTask.survey.rawValue.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    if identifier == CheckIn.identifier() {

                        let feeling = event.answerString(kind: CheckIn.feelingItemIdentifier)
                        let dayTurnOut = event.answerString(kind: CheckIn.dayTurnOutItemIdentifier)
                        view.instructionsLabel.text = """
                        You are feeling \(feeling)
                        Are you enjoying Track?: \(dayTurnOut)
                        """
                    } else if identifier == Motivate.identifier() {
                        let videoFinished = event.answerString(kind: Motivate.motivationIdentifier)
                        view.instructionsLabel.text = """
                        \(videoFinished)
                        """
                    }

                } else {
                    if let instructions = surveyTask.instructions {

                        view.instructionsLabel.text = """
                        \(instructions)
                        """
                    }
                }

            } else {
                view.instructionsLabel.text = "Track Survey"
            }
        }
}
