//
//  Motivate.swift
//  OCKSample
//
//  Created by seun on 12/11/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitStore
#if canImport(ResearchKit)
import ResearchKit
#endif

struct Motivate: Surveyable {
    static var surveyType: Survey {
        Survey.motivate
    }

    static var formIdentifier: String {
        "\(Self.identifier()).form"
    }

    static var motivationIdentifier: String {
        "\(Self.identifier()).form.motivation"
    }

}

#if canImport(ResearchKit)
extension Motivate {
    func createSurvey() -> ORKTask {

        let videoStep = ORKVideoInstructionStep(identifier: Self.formIdentifier)
        videoStep.title = NSLocalizedString("Watch this video to be inspired", comment: "")
        videoStep.text = "The kick you need to get back on Track"
        // swiftlint:disable:next line_length
        videoStep.videoURL = URL(string: "https://github.com/seunadekunle/seunadekunle.github.io/raw/master/Best%20Short%20Motivational%20Speech%20Video%20-%2024%20HOURS%20-%201-Minute%20Motivation%20%232.mp4")
        videoStep.thumbnailTime = 2

        let surveyTask = ORKOrderedTask(
            identifier: identifier(),
            steps: [videoStep]
        )
        return surveyTask

    }

    func extractAnswers(_ result: ORKTaskResult) -> [OCKOutcomeValue]? {

        guard
            let response = result.results?
                .compactMap({ $0 as? ORKStepResult })
                .first(where: { $0.identifier == Self.formIdentifier }),

                let videoResult = response
                .results?.compactMap({ $0 as? ORKVideoInstructionStepResult })
        else {
            assertionFailure("Failed to extract answers from motivate survey!")
            return []
        }

        let playbackCompleted = videoResult[0].playbackCompleted

        // fills out the appropriate data type based on input
        var videoFinishedValue: OCKOutcomeValue
        if playbackCompleted {
            videoFinishedValue = OCKOutcomeValue("Video Finished ✊")
        } else {
            videoFinishedValue = OCKOutcomeValue("Watched for\(round(videoResult[0].playbackStoppedTime)) s")
        }

        videoFinishedValue.kind = Self.motivationIdentifier

        return [videoFinishedValue]
    }
}
#endif
