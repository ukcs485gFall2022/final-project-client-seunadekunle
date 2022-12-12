/*
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3. Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation
import UIKit
import SwiftUI
import Combine
import CareKit
import CareKitStore
import CareKitUI
import os.log
import ResearchKit

class CareViewController: OCKDailyPageViewController {

    private var isSyncing = false
    private var isLoading = false
    private let colorStyler = ColorStyler()
    @ObservedObject var careViewModel: CareViewModel

    // swiftlint:disable:next line_length
    init(storeManager: OCKSynchronizedStoreManager, adherenceAggregator: OCKAdherenceAggregator = .compareTargetValues, careViewModel: CareViewModel) {
        self.careViewModel = careViewModel
        super.init(storeManager: storeManager)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh,
            target: self,
            action: #selector(synchronizeWithRemote))
        NotificationCenter.default.addObserver(self, selector: #selector(synchronizeWithRemote),
            name: Notification.Name(rawValue: Constants.requestSync),
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(updateSynchronizationProgress(_:)),
            name: Notification.Name(rawValue: Constants.progressUpdate),
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(reloadView(_:)),
            name: Notification.Name(rawValue: Constants.finishedAskingForPermission),
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(reloadView(_:)),
            name: Notification.Name(rawValue: Constants.shouldRefreshView),
            object: nil)
    }

    @objc private func updateSynchronizationProgress(_ notification: Notification) {
        guard let receivedInfo = notification.userInfo as? [String: Any],
            let progress = receivedInfo[Constants.progressUpdate] as? Int else {
            return
        }

        DispatchQueue.main.async {
            switch progress {
            case 0, 100:
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "\(progress)",
                    style: .plain, target: self,
                    action: #selector(self.synchronizeWithRemote))
                if progress == 100 {
                    // Give sometime for the user to see 100
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        // swiftlint:disable:next line_length
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.synchronizeWithRemote))
                        // swiftlint:disable:next line_length
                        self.navigationItem.rightBarButtonItem?.tintColor = self.navigationItem.leftBarButtonItem?.tintColor
                    }
                }
            default:
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "\(progress)",
                    style: .plain, target: self,
                    action: #selector(self.synchronizeWithRemote))
                self.navigationItem.rightBarButtonItem?.tintColor = TintColorKey.defaultValue
            }
        }

        self.careViewModel.trackScore += 1
    }

    @MainActor
    @objc private func synchronizeWithRemote() {
        guard !isSyncing else {
            return
        }
        isSyncing = true
        AppDelegateKey.defaultValue?.store?.synchronize { error in
            let errorString = error?.localizedDescription ?? "Successful sync with remote!"
            Logger.feed.info("\(errorString)")
            DispatchQueue.main.async {
                if error != nil {
                    // swiftlint:disable:next line_length
                    self.navigationItem.rightBarButtonItem?.tintColor = CustomStylerKey.defaultValue.color.quaternaryCustomFill
                } else {
                    self.navigationItem.rightBarButtonItem?.tintColor = self.navigationItem.leftBarButtonItem?.tintColor
                }
                self.isSyncing = false
            }
        }
    }

    @objc private func reloadView(_ notification: Notification? = nil) {
        guard !isLoading else {
            return
        }
        DispatchQueue.main.async {
            self.isLoading = true
            self.reload()
        }
    }

    /*
     This will be called each time the selected date changes.
     Use this as an opportunity to rebuild the content shown to the user.
     */ // swiftlint:disable:next line_length
    override func dailyPageViewController(_ dailyPageViewController: OCKDailyPageViewController, prepare listViewController: OCKListViewController, for date: Date) {

        Task {
            guard await checkIfOnboardingIsComplete() else {
                let onboardSurvey = Onboard()
                let onboardCard = OCKSurveyTaskViewController(taskID: onboardSurvey.identifier(),
                    eventQuery: OCKEventQuery(for: date),
                    storeManager: self.storeManager,
                    survey: onboardSurvey.createSurvey(),
                    extractOutcome: onboardSurvey.extractAnswers)
                if let carekitView = onboardCard.view as? OCKView {
                    carekitView.customStyle = CustomStylerKey.defaultValue
                }
                onboardCard.surveyDelegate = self
                onboardCard.title = "Onboard"

                listViewController.appendViewController(
                    onboardCard,
                    animated: false
                )
                return
            }

            let isCurrentDay = Calendar.current.isDate(date, inSameDayAs: Date())

            // Only show the custom view on the current date
            if isCurrentDay {
                if Calendar.current.isDate(date, inSameDayAs: Date()) {
                    // Add a non-CareKit view into the list
                    let viewTitle = "Start Tracking Your Habits"

                    let customView = CustomFeaturedContentView()
                    customView.url = URL(string: "https://wealthygorilla.com/7-reasons-start-tracking-your-habits/")
                    customView.imageView.image = UIImage(named: "pexels-fall")
                    customView.label.text = viewTitle
                    customView.label.textColor = UIColor(red: 0.75, green: 0.70, blue: 0.65, alpha: 1.00)
                    customView.customStyle = CustomStylerKey.defaultValue

                    listViewController.appendView(customView, animated: false)
                }
            }

            let tasks = await self.fetchTasks(on: date)
            tasks.compactMap {
                let cards = self.taskViewController(for: $0, on: date)
                cards?.forEach {
                    if let carekitView = $0.view as? OCKView {
                        carekitView.customStyle = CustomStylerKey.defaultValue
                    }
                    $0.view.isUserInteractionEnabled = isCurrentDay
                    $0.view.alpha = !isCurrentDay ? 0.4 : 1.0
                }
                return cards
            }.forEach { (cards: [UIViewController]) in
                cards.forEach {
                    listViewController.appendViewController($0, animated: false)
                }
            }
            self.isLoading = false
        }
    }

    // swiftlint:disable cyclomatic_complexity
    private func getViewType(_ type: String?, _ task: OCKAnyTask, _ date: Date) -> [UIViewController]? {
        switch type {
        case ViewType.numericProgressTaskView.rawValue:
            let view = NumericProgressTaskView(
                task: task,
                eventQuery: OCKEventQuery(for: date),
                storeManager: self.storeManager)
                .padding([.vertical], 20)
                .careKitStyle(CustomStylerKey.defaultValue)

            // swiftlint:disable:next line_length
            let linkView = LinkView(title: .init("Give us a rating on the App Store"), links: [.website("https://www.apple.com/app-store/", title: "Rating")])

            return [view.formattedHostingController(), linkView.formattedHostingController()]

        case ViewType.instructionsTaskView.rawValue:
            return [OCKInstructionsTaskViewController(task: task,
                eventQuery: .init(for: date),
                storeManager: self.storeManager)]

        case ViewType.simpleTaskView.rawValue:
            return [OCKSimpleTaskViewController(task: task,
                eventQuery: .init(for: date),
                storeManager: self.storeManager)]

        case ViewType.checklist.rawValue:
            return [OCKChecklistTaskViewController(
                task: task,
                eventQuery: .init(for: date),
                storeManager: self.storeManager)]

        case ViewType.buttonLog.rawValue:
            return [OCKButtonLogTaskViewController(task: task,
                eventQuery: .init(for: date),
                storeManager: self.storeManager)]

        case ViewType.gridTaskView.rawValue:
            return [OCKGridTaskViewController(task: task, eventQuery: .init(for: date), storeManager: storeManager)]

        case ViewType.survey.rawValue:
            guard let surveyTask = task as? OCKTask else {
                Logger.feed.error("Can only use a survey for an \"OCKTask\", not \(task.id)")
                return nil
            }

            if surveyTask.id == Onboard().identifier() {
                return nil
            }

            // swiftlint:disable:next line_length
            let surveyCard = OCKSurveyTaskViewController(taskID: surveyTask.survey.type().identifier(), eventQuery: OCKEventQuery(for: date),
                storeManager: self.storeManager,
                survey: surveyTask.survey.type().createSurvey(),
                viewSynchronizer: SurveyViewSynchronizer(),
                extractOutcome: surveyTask.survey.type().extractAnswers

            )
            surveyCard.surveyDelegate = self
            return [surveyCard]
        case ViewType.counter.rawValue:
            let viewModel = CounterCardViewModel(task: task,
                eventQuery: .init(for: date),
                storeManager: self.storeManager)
            let customCard = CounterCardView(viewModel: viewModel)
            return [customCard.formattedHostingController()]
        case ViewType.logger.rawValue:
            let viewModel = LoggerCardViewModel(task: task,
                eventQuery: .init(for: date),
                storeManager: self.storeManager)
            let customCard = LoggerCardView(viewModel: viewModel)
            return [customCard.formattedHostingController()]
        default:
            let taskView = LabeledValueTaskView(
                task: task,
                eventQuery: OCKEventQuery(for: date),
                storeManager: self.storeManager)
                .padding([.vertical], 20)
                .careKitStyle(CustomStylerKey.defaultValue)

            return [taskView.formattedHostingController()]
        }
    }

    private func taskViewController(for task: OCKAnyTask, on date: Date) ->
    [UIViewController]? {
        var type: String? = ViewType.labeledValueTaskView.rawValue

        if let ockTask = task as? OCKTask, let userInfo = ockTask.userInfo {
            type = userInfo[Constants.viewTypeKey]
        } else if let healthTask = task as? OCKHealthKitTask, let userInfo = healthTask.userInfo {
            type = userInfo[Constants.viewTypeKey]
        }

        return getViewType(type, task, date)
    }

    private func fetchTasks(on date: Date) async -> [OCKAnyTask] {

        do {
            var query = OCKTaskQuery(for: date)
            query.excludesTasksWithNoEvents = false

            let tasks = try await storeManager.store.fetchAnyTasks(query: query)

            //            let orderedTasks = TaskID.ordered.compactMap { orderedTaskID in
            //                tasks.first(where: { $0.id == orderedTaskID }) }
            //            for task in orderedTasks {
            //                Logger.feed.info(task.title)
            //            }
            return tasks
        } catch {
            Logger.feed.error("\(error.localizedDescription, privacy: .public)")
            return []
        }
    }

    @MainActor
    private func checkIfOnboardingIsComplete() async -> Bool {
        var query = OCKOutcomeQuery()
        query.taskIDs = [Onboard.identifier()]

        guard let store = AppDelegateKey.defaultValue?.store else {
            Logger.feed.error("CareKit store could not be unwrapped")
            return false
        }

        do {
            let outcomes = try await store.fetchAnyOutcomes(query: query)
            return !outcomes.isEmpty
        } catch {
            return false
        }
    }
}

extension CareViewController: OCKSurveyTaskViewControllerDelegate {
    func surveyTask(
        viewController: OCKSurveyTaskViewController,
        for task: OCKAnyTask,
        didFinish result: Result<ORKTaskViewControllerFinishReason, Error>) {

        if case let .success(reason) = result, reason == .completed {
            reload()
        } else {
            Logger.careViewController.error("Couldn't save survey task")
        }

    }
}

extension View {
    func formattedHostingController() -> UIHostingController<Self> {
        let viewController = UIHostingController(rootView: self)
        viewController.view.backgroundColor = .clear
        return viewController
    }
}
