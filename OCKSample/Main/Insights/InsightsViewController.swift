//
//  InsightsViewController.swift
//  OCKSample
//
//  Created by Corey Baker on 12/5/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//
/*
 You should notice this looks like CareViewController and
 MyContactViewController combined,
 but only shows charts instead.
 */

import UIKit
import CareKitStore
import CareKitUI
import CareKit
import ParseSwift
import ParseCareKit
import os.log

class InsightsViewController: OCKListViewController {

    let colors = [ColorStyler.iconBlue, ColorStyler.iconRed, ColorStyler.iconBlue, .systemGray2, .systemGray]
    /// The manager of the `Store` from which the `Contact` data is fetched.
    public let storeManager: OCKSynchronizedStoreManager

    /// Initialize using a store manager. All of the contacts in the store manager will be queried and dispalyed.
    ///
    /// - Parameters:
    ///   - storeManager: The store manager owning the store whose contacts should be displayed.
    public init(storeManager: OCKSynchronizedStoreManager) {
        self.storeManager = storeManager
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Insights"

        Task {
            await displayTasks(Date())
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        Task {
            await displayTasks(Date())
        }
    }

    override func appendViewController(_ viewController: UIViewController, animated: Bool) {
        super.appendViewController(viewController, animated: animated)

        // Make sure this contact card matches app style when possible
        if let carekitView = viewController.view as? OCKView {
            carekitView.customStyle = CustomStylerKey.defaultValue
        }
    }

    @MainActor
    func fetchTasks(on date: Date) async -> [OCKAnyTask] {
        /**
         T0DO: How would you modify this to fetch all of your tasks?
         Hint - you should look at the same function in CareViewController. If you
         understand queries and filters, this will be straightforward.
         */
        var query = OCKTaskQuery(for: date)
        query.excludesTasksWithNoEvents = true
        do {
            let tasks = try await storeManager.store.fetchAnyTasks(query: query)
            //            var taskIDs = TaskID.ordered
            //            taskIDs.append(CheckIn().identifier())
            //            let orderedTasks = taskIDs.compactMap { orderedTaskID in
            //                tasks.first(where: { $0.id == orderedTaskID }) }
            return tasks
        } catch {
            Logger.insights.error("\(error.localizedDescription, privacy: .public)")
            return []
        }
    }

    /*
     T0DO: Plot all of your tasks in this method. Note that you can combine multiple
     tasks into one chart (like the Nausea/Doxlymine chart if they are related.
     */

    func taskViewController(for task: OCKAnyTask,
                            on date: Date) -> [UIViewController]? {
        /*
         T0DO: CareKit has 3 plotType's: .bar, .scatter, and .line.
         You should have a 3 types in your InsightView meaning you
         should have at least 3 charts. Remember that all of your
         tasks need to be graphed so you may have more. The solution
         for not this should not be to show all 3 plot types for a
         single task. Your code should be flexible enough to determine
         a graph type. Instead, you should look extend OCKTask and OCKAnyTask
         to add a "graph" property similar to "card". This means you probably
         should create a "GraphCard" enum similar to "CareKitCard" and allow
         the user to select the specific graph when adding a new task.
         Hint - you should look at the same function in CareViewController
         to determine how to switch graphs on an enum.
         */

        //        let survey = CheckIn() // Only used for example.
        //        let surveyTaskID = survey.identifier() // Only used for example.

        // won't show onboard task
        if task.id == TaskID.onboard {
            return nil
        }

        var plotType: String? = PlotType.bar.rawValue

        if let ockTask = task as? OCKTask, let userInfo = ockTask.userInfo {
            plotType = userInfo[Constants.plotTypeKey]
        } else if let healthTask = task as? OCKHealthKitTask, let userInfo = healthTask.userInfo {
            plotType = userInfo[Constants.plotTypeKey]
        }

        let start = Int.random(in: 0...colors.count-1)
        let end = Int.random(in: 0...colors.count-1)

        var plot: OCKCartesianGraphView.PlotType = .bar

        // Create a plot comparing mean to median.
        let dataSeries = OCKDataSeriesConfiguration(
            taskID: task.id,
            legendTitle: task.title ?? "Task",
            gradientStartColor: colors[start],
            gradientEndColor: colors[end],
            markerSize: 10,
            eventAggregator: OCKEventAggregator.aggregatorStreak())

        switch plotType {
        case PlotType.line.rawValue:
            plot = .line
        case PlotType.scatter.rawValue:
            plot = .scatter
        case PlotType.bar.rawValue:
            // swiftlint:disable no_fallthrough_only
            fallthrough
        default:
            plot = .bar
        }

        // Create a plot comparing nausea to medication adherence.
        let insightsCard = OCKCartesianChartViewController(
            plotType: plot,
            selectedDate: date,
            configurations: [dataSeries],
            storeManager: self.storeManager)

        insightsCard.chartView.headerView.titleLabel.text = task.title
        insightsCard.chartView.headerView.detailLabel.text = task.instructions
        insightsCard.chartView.headerView.accessibilityLabel = task.instructions

        return [insightsCard]
    }

    @MainActor
    func displayTasks(_ date: Date) async {

        let tasks = await fetchTasks(on: date)
        self.clear() // Clear after pulling tasks from database
        tasks.compactMap {
            let cards = self.taskViewController(for: $0, on: date)
            cards?.forEach {
                if let carekitView = $0.view as? OCKView {
                    carekitView.customStyle = CustomStylerKey.defaultValue
                }
            }
            return cards
        }.forEach { (cards: [UIViewController]) in
            cards.forEach {
                self.appendViewController($0, animated: false)
            }
        }
    }
}
