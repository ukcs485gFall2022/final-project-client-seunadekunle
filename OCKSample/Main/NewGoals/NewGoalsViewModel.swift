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

@MainActor
class NewGoalsViewModel: ObservableObject {

    @Published var error: AppError?

    @Published public var title = ""
    @Published public var instructions = ""
    @Published public var taskType = "Normal"
    @Published public var ockTaskTypes = ["Normal", "Health"]

    @Published public var start = Date()
    @Published public var end = Date()
    @Published public var viewType = ViewType.labeledValueTaskView
    @Published public var plotType = PlotType.bar
    @Published public var plan = OCKCarePlan(id: UUID().uuidString,
        title: "Check in Care Plan", patientUUID: nil)
    @Published public var plans = [OCKCarePlan(id: UUID().uuidString,
        title: "Check in Care Plan",
        patientUUID: nil)]

    @Published var isShowingAddAlert = false
    private(set) var alertMessage = "All changs saved successfully!"

    var assetName = "figure.stairs"

    init() {
        getCarePlans()
    }

    // Adds a normal task
    func addNormalTask(taskSchedule: OCKSchedule) async {

        var task = OCKTask(id: UUID().uuidString, title: title, carePlanUUID: nil, schedule: taskSchedule)
        task.instructions = instructions
        task.asset = assetName
        task.userInfo = [Constants.viewTypeKey: viewType.rawValue, Constants.plotTypeKey: plotType.rawValue]
        task.carePlanUUID = self.plan.uuid

        do {
            guard let appDelegate = AppDelegateKey.defaultValue else {
                self.error = AppError.couldntBeUnwrapped
                return
            }
            try await appDelegate.store?.addTasksIfNotPresent([task])

            // Automatically refresh view
            NotificationCenter.default.post(.init(name: Notification.Name(rawValue: Constants.shouldRefreshView)))
        } catch {
            self.error = AppError.errorString("Could not add new task \(error.localizedDescription)")

            alertMessage = "Could not add user task: \(error)"
            isShowingAddAlert = true
        }
    }

    // Adds an HealthKit Task
    func addHealthKitTask(taskSchedule: OCKSchedule, healthTask: String) async {

        var healthKitLinkage: OCKHealthKitLinkage = OCKHealthKitLinkage(
            quantityIdentifier: .dietaryWater,
            quantityType: .cumulative,
            unit: .cupUS())
        if healthTask == "Counting Sugar" {
            healthKitLinkage = HealthKitLinkages.countingSugar
        } else if healthTask == "Water intake" {
            healthKitLinkage = HealthKitLinkages.waterIntake
        } else if healthTask == "Protein" {
            healthKitLinkage = HealthKitLinkages.protein
        } else if healthTask == "Flights Climbed" {
            healthKitLinkage = HealthKitLinkages.flightsClimbed
        }

        var healthKitTask = OCKHealthKitTask(
            id: UUID().uuidString,
            title: title,
            carePlanUUID: nil,
            schedule: taskSchedule,
            healthKitLinkage: healthKitLinkage)
        healthKitTask.instructions = instructions
        healthKitTask.asset = assetName
        healthKitTask.userInfo = [Constants.viewTypeKey: viewType.rawValue, Constants.plotTypeKey: plotType.rawValue]
        healthKitTask.carePlanUUID = self.plan.uuid

        do {
            guard let appDelegate = AppDelegateKey.defaultValue else {
                self.error = AppError.couldntBeUnwrapped
                return
            }
            try await appDelegate.healthKitStore.addTasksIfNotPresent([healthKitTask])

            // HealthKit Store permissions
            Utility.requestHealthKitPermissions()

            // Automatically refresh view
            NotificationCenter.default.post(.init(name: Notification.Name(rawValue: Constants.shouldRefreshView)))
        } catch {
            self.error = AppError.errorString("Could not add new task \(error.localizedDescription)")

            alertMessage = "Could not add task: \(error)"
            isShowingAddAlert = true
        }
    }

    // General function for all tasks called by button
    func addTask(freq: String = "Daily", newAssetName: String, healthTask: String? = nil) async {

        if end <= start {
            self.error = AppError.errorString("Start date must before end Date")
            return
        }

        if assetName != newAssetName {
            assetName = newAssetName
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
        } else if freq == "Hourly" {
            let scheduleElement = OCKScheduleElement.init(start: start, end: end, interval: DateComponents(hour: 1))
            taskSchedule = OCKSchedule(composing: [scheduleElement])
        } else {
            let scheduleElement = OCKScheduleElement.init(start: start, end: end, interval: DateComponents(month: 1))
            taskSchedule = OCKSchedule(composing: [scheduleElement])
        }

        if taskType == "Normal" {
            await addNormalTask(taskSchedule: taskSchedule)
        } else if taskType == "Health" {
            if let healthTaskString = healthTask {
                await addHealthKitTask(taskSchedule: taskSchedule, healthTask: healthTaskString)
            } else {
                return
            }
        }
    }

    func getCarePlans() {
        Task {
            await queryCarePlans()
        }
    }

    func queryCarePlans() async {

        var fetchedPlans: [OCKCarePlan] = []

        do {
            guard let appDelegate = AppDelegateKey.defaultValue else {
                self.error = AppError.couldntBeUnwrapped
                self.plans = plans
                return
            }

            let query = OCKCarePlanQuery()
            if let queriedPlans = try await appDelegate.store?.fetchCarePlans(query: query) {
                fetchedPlans = queriedPlans
            }

        } catch {
            alertMessage = "Could not get care plan: \(error)"
            isShowingAddAlert = true
        }

        // runs on main thread
        DispatchQueue.main.async {
            self.plans = fetchedPlans
            self.plan = self.plans[0]
        }
    }
}
