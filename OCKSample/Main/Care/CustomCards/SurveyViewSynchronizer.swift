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
            /*
             t0do: You need to modify this so the instuction label shows
             correctly for each Task/Card.
             Hint - Each event (OCKAnyEvent) has a task. How can you use
             this task to determine what instruction answers should show?
             Look at how the CareViewController differentiates between
             surveys.
             */

//            event.task.title
//            event.task.instructions
//            event.task.
//
//            let pain = event.answer(kind: CheckIn.painItemIdentifier)
//            let sleep = event.answer(kind: CheckIn.sleepItemIdentifier)

            if let instructions = event.task.instructions {
                view.instructionsLabel.text = """
                    \(instructions)
                    """
            }

        } else {
            view.instructionsLabel.text = "Take Survey"
        }
    }
}
