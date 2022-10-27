//
//  NewGoalsViewModel.swift
//  OCKSample
//
//  Created by seun on 10/26/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import SwiftUI
import CareKit
import CareKitUI
import CareKitStore
import HealthKit
import os.log

class NewGoalsViewModel: ObservableObject {
    // MARK: Public read, private write properties
    @Published private(set) var task: OCKTask?
    private(set) var storeManager: OCKSynchronizedStoreManager

    init(storeManager: OCKSynchronizedStoreManager? = nil) {
        self.storeManager = storeManager ?? StoreManagerKey.defaultValue
    }

    // swiftlint:disable:next line_length
    func addHabit(title: String, instructions: String, start: Date, end: Date, freq: String = "Daily", taskID: String) async throws {
        let date = Date()
        var calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)

        var taskSchedule: OCKSchedule
        if freq == "Daily" {
            taskSchedule = OCKSchedule.dailyAtTime(hour: hour, minutes: minute, start: start, end: end, text: "")
        } else if freq == "Weekly" {
            // swiftlint:disable:next line_length
            taskSchedule = OCKSchedule.weeklyAtTime(weekday: day, hours: hour, minutes: minute, start: start, end: end, targetValues: [], text: "")
        } else {
            let scheduleElement = OCKScheduleElement.init(start: start, end: end, interval: DateComponents(month: 1))
            taskSchedule = OCKSchedule(composing: [scheduleElement])
        }

        var task = OCKTask(id: taskID, title: title, carePlanUUID: nil, schedule: taskSchedule)
        task.instructions = instructions

        // This is new patient that has never been saved before
        let addedTask = try await storeManager.store.addAnyTask(task)
        guard let addedOCKTask = addedTask as? OCKTask else {
            Logger.profile.error("Could not cast to OCKPatient")
            return
        }
        self.task = addedOCKTask

//        OCKStore.init(name: <#T##String#>)
//        addTasksIfNotPresent([task])

//        taskViewController = OCKGridTaskViewController(taskID: OCKStore.Tasks.doxylamine.rawValue,
//                                                       eventQuery: .init(for: Date()), storeManager: storeManager)
//
//        @State var storeManager = StoreManagerKey.defaultValue
//        let careViewcontroller = await CareViewController(storeManager: storeManager)

//        careViewcontroller.

    }
}
