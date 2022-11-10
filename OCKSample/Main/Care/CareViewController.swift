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
import ResearchKit
import os.log

class CareViewController: OCKDailyPageViewController {

    private var isSyncing = false
    private var isLoading = false

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
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh,
                            target: self,
                            action: #selector(self.synchronizeWithRemote))
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
    override func dailyPageViewController(_ dailyPageViewController: OCKDailyPageViewController, prepare listViewController: OCKListViewController, for date: Date) async {
        
        guard await checkIfOnboardingIsComplete() else {

                        let onboardCard = OCKSurveyTaskViewController(
                                            taskID: TaskID.onboarding,
                                            eventQuery: OCKEventQuery(for: date),
                                            storeManager: self.storeManager,
                                            survey: Surveys.onboardingSurvey(),
                                            extractOutcome: { _ in [OCKOutcomeValue(Date())] }
                                        )
                        onboardCard.surveyDelegate = self

                        listViewController.appendViewController(
                            onboardCard,
                            animated: false
                        )
                        return
                    }
        
        let isCurrentDay = Calendar.current.isDate(date, inSameDayAs: Date())

        // Only show the tip view on the current date
        if isCurrentDay {
            if Calendar.current.isDate(date, inSameDayAs: Date()) {
                // Add a non-CareKit view into the list
                let tipTitle = "The science of habits"
                let tipText = "knowablemagazine.org"
                let tipView = TipView()
                tipView.headerView.titleLabel.text = tipTitle
                tipView.headerView.detailLabel.text = tipText
                tipView.imageView.image = UIImage(named: "article_icon")
                tipView.customStyle = CustomStylerKey.defaultValue
                listViewController.appendView(tipView, animated: false)
            }
        }

        Task {
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

    private func taskViewController(for task: OCKAnyTask, on date: Date) ->
    [UIViewController]? {
        var type: String? = ViewType.labeledValueTaskView.rawValue

        if let ockTask = task as? OCKTask, let userInfo = ockTask.userInfo {
            type = userInfo["ViewType"]
        } else if let healthTask = task as? OCKHealthKitTask, let userInfo = healthTask.userInfo {
            type = userInfo["ViewType"]
        }

        switch type {
        case ViewType.numericProgressTaskView.rawValue:
            let linkView = LinkView(title: .init(""), links: [.website("https://www.wsj.com/", title: "WSJ")])
            let view = NumericProgressTaskView(
                task: task,
                eventQuery: OCKEventQuery(for: date),
                storeManager: self.storeManager)
                .padding([.vertical], 20)
                .careKitStyle(CustomStylerKey.defaultValue)

            return [linkView.formattedHostingController(), view.formattedHostingController()]

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
            var cards = [UIViewController]()
            if task.id == TaskID.nausea {
                    // dynamic gradient colors
                    let nauseaGradientStart = UIColor { _ in
                        return UIColor(Color(TintColorKey.defaultValue))
                    }
                    let nauseaGradientEnd = UIColor { _ in
                        return UIColor(Color(TintColorKey.defaultValue))
                    }

                    // Create a plot comparing nausea to medication adherence.
                    let nauseaDataSeries = OCKDataSeriesConfiguration(
                        taskID: "nausea",
                        legendTitle: "Nausea",
                        gradientStartColor: nauseaGradientStart,
                        gradientEndColor: nauseaGradientEnd,
                        markerSize: 10,
                        eventAggregator: OCKEventAggregator.countOutcomeValues)

                    let doxylamineDataSeries = OCKDataSeriesConfiguration(
                        taskID: "doxylamine",
                        legendTitle: "Doxylamine",
                        gradientStartColor: .systemGray2,
                        gradientEndColor: .systemGray,
                        markerSize: 10,
                        eventAggregator: OCKEventAggregator.countOutcomeValues)

                    let insightsCard = OCKCartesianChartViewController(
                        plotType: .bar,
                        selectedDate: date,
                        configurations: [nauseaDataSeries, doxylamineDataSeries],
                        storeManager: self.storeManager)

                    insightsCard.chartView.headerView.titleLabel.text = "Nausea & Doxylamine Intake"
                    insightsCard.chartView.headerView.detailLabel.text = "This Week"
                    insightsCard.chartView.headerView.accessibilityLabel = "Nausea & Doxylamine Intake, This Week"
                    cards.append(insightsCard)
                }

            /*
             Also create a card that displays a single event.
             The event query passed into the initializer specifies that only
             today's log entries should be displayed by this log task view controller.
             */
            let buttonLogCard = OCKButtonLogTaskViewController(task: task,
                eventQuery: .init(for: date),
                storeManager: self.storeManager)
            cards.append(buttonLogCard)
            return cards

        case ViewType.gridTaskView.rawValue:
            return [OCKGridTaskViewController(task: task, eventQuery: .init(for: date), storeManager: storeManager)]

        default:
            let taskView = LabeledValueTaskView(title: Text(task.title ?? "")) {
                Text(task.instructions ?? "")
            }.careKitStyle(CustomStylerKey.defaultValue)

            return [taskView.formattedHostingController()]
        }
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
    
    private func checkIfOnboardingIsComplete() async -> Bool {

           var query = OCKOutcomeQuery()
           query.taskIDs = [TaskID.onboarding]

           // swiftlint:disable:next force_cast
           let appDelegate = UIApplication.shared.delegate as! AppDelegate

           guard let store = appDelegate.store else {
               Logger.feed.error("CareKit store couldn't be unwrapped")
               return false
           }

           do {
               let outcomes = try await store.fetchOutcomes(query: query)
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
            }
        }
}
    

private extension View {
    func formattedHostingController() -> UIHostingController<Self> {
        let viewController = UIHostingController(rootView: self)
        viewController.view.backgroundColor = .clear
        return viewController
    }
}
