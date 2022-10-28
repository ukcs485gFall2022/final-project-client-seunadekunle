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

    @Published var error: AppError?
//    @State var instructions = ""

    // swiftlint:disable:next line_length
    func addTask(title: String, instructions: String, start: Date, end: Date, freq: String = "Daily", taskID: String) async {

        if end <= start {
            self.error = AppError.errorString("Start date must before end Date")
            return
        }

        let date = Date()
        let calendar = Calendar.current
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

//        var updatedTask = task

//        if instructions != updatedTask.instructions {
            //        updatedTask?.instructions = instructions
//        }
        var task = OCKTask(id: taskID, title: title, carePlanUUID: nil, schedule: taskSchedule)
        task.instructions = instructions

        do {
            guard let appDelegate = AppDelegateKey.defaultValue else {
                self.error = AppError.couldntBeUnwrapped
                return
            }

            try await appDelegate.store?.addTasksIfNotPresent([task])
        } catch {
            self.error = AppError.errorString("Could not add new task \(error.localizedDescription)")
        }
    }
}
