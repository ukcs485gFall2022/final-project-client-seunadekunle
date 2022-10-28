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

    @Published public var taskID = ""
    @Published public var title = ""
    @Published public var instructions = ""
    @Published public var start = Date()
    @Published public var end = Date()

    func addNormalTask(taskSchedule: OCKSchedule) async {

        var task = OCKTask(id: TaskID.multistep, title: title, carePlanUUID: nil, schedule: taskSchedule)
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

    func addHealthTask(taskSchedule: OCKSchedule, healthTask: String) async {

        var healthKitLinkage: OCKHealthKitLinkage = OCKHealthKitLinkage(
            quantityIdentifier: .dietaryWater,
            quantityType: .cumulative,
            unit: .cupUS())
        if healthTask == "Counting Calories" {
            healthKitLinkage = OCKHealthKitLinkage(quantityIdentifier: .dietarySugar,
                quantityType: .cumulative,
                unit: .gram())
        } else if healthTask == "Water intake" {
            healthKitLinkage = OCKHealthKitLinkage(quantityIdentifier: .dietaryWater,
                quantityType: .cumulative,
                unit: .fluidOunceUS())
        } else if healthTask == "Protein" {
            healthKitLinkage = OCKHealthKitLinkage(quantityIdentifier: .dietaryProtein,
                quantityType: .cumulative,
                unit: .gram())
        } else if healthTask == "Flights Climbed" {
            healthKitLinkage = OCKHealthKitLinkage(quantityIdentifier: .flightsClimbed,
                quantityType: .cumulative,
                unit: .count())
        }

        var healthKitTask = OCKHealthKitTask(
            id: TaskID.healthSugar,
            title: title,
            carePlanUUID: nil,
            schedule: taskSchedule,
            healthKitLinkage: healthKitLinkage)
        healthKitTask.instructions = instructions

        do {
            guard let appDelegate = AppDelegateKey.defaultValue else {
                self.error = AppError.couldntBeUnwrapped
                return
            }
            try await appDelegate.healthKitStore.addTasksIfNotPresent([healthKitTask])
        } catch {
            self.error = AppError.errorString("Could not add new task \(error.localizedDescription)")
        }
    }

    func addTask(freq: String = "Daily", taskType: String, healthTask: String? = nil) async {

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

        if taskType == "Normal" {
            await addNormalTask(taskSchedule: taskSchedule)
        } else if taskType == "Health" {
            if let healthTaskString = healthTask {
                await addHealthTask(taskSchedule: taskSchedule, healthTask: healthTaskString)
            } else {
                return
            }
        }
    }
}
