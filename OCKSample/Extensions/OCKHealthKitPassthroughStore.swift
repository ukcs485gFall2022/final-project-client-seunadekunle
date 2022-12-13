//
//  OCKHealthKitPassthroughStore.swift
//  OCKSample
//
//  Created by Corey Baker on 1/5/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitStore
import HealthKit
import os.log

extension OCKHealthKitPassthroughStore {

    func addTasksIfNotPresent(_ tasks: [OCKHealthKitTask]) async throws {
        let tasksToAdd = tasks
        let taskIdsToAdd = tasksToAdd.compactMap { $0.id }

        // Prepare query to see if tasks are already added
        var query = OCKTaskQuery(for: Date())
        query.ids = taskIdsToAdd

        let foundTasks = try await fetchTasks(query: query)
        var tasksNotInStore = [OCKHealthKitTask]()

        // Check results to see if there's a missing task
        tasksToAdd.forEach { potentialTask in
            if foundTasks.first(where: { $0.id == potentialTask.id }) == nil {
                tasksNotInStore.append(potentialTask)
            }
        }

        // Only add if there's a new task
        if tasksNotInStore.count > 0 {
            do {
                _ = try await addTasks(tasksNotInStore)
                Logger.ockHealthKitPassthroughStore.info("Added tasks into HealthKitPassthroughStore!")
            } catch {
                Logger.ockHealthKitPassthroughStore.error("Error adding HealthKitTasks: \(error.localizedDescription)")
            }
        }
    }

    func populateSampleData(_ patientUUID: UUID? = nil) async throws {

        let schedule1 = OCKSchedule.dailyAtTime(
            hour: 6, minutes: 0, start: Date(), end: nil, text: nil,
            duration: .hours(16), targetValues: [OCKOutcomeValue(600, units: "mL")])

        let schedule2 = OCKSchedule.dailyAtTime(
            hour: 9, minutes: 0, start: Date(), end: nil, text: "Sugar",
            duration: .hours(24))

        var drinkWater = OCKHealthKitTask(
            id: TaskID.drinkWater,
            title: "Drink Water",
            carePlanUUID: patientUUID,
            schedule: schedule1,
            healthKitLinkage: HealthKitLinkages.waterIntake)
        drinkWater.asset = "drop.fill"
        drinkWater.userInfo = [Constants.viewTypeKey: ViewType.numericProgressTaskView.rawValue]

        var countSugar = OCKHealthKitTask(
            id: TaskID.countSugar,
            title: "Count Sugar",
            carePlanUUID: patientUUID,
            schedule: schedule2,
            healthKitLinkage: HealthKitLinkages.countingSugar)
        countSugar.asset = "fork.knife.circle.fill"
        countSugar.userInfo = [Constants.viewTypeKey: ViewType.labeledValueTaskView.rawValue]

        try await addTasksIfNotPresent([drinkWater, countSugar])
    }
}
