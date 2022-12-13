//
//  OCKStore.swift
//  OCKSample
//
//  Created by Corey Baker on 1/5/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitStore
import Contacts
import os.log
import ParseSwift
import ParseCareKit

extension OCKStore {
    func addTasksIfNotPresent(_ tasks: [OCKTask]) async throws {
        let taskIdsToAdd = tasks.compactMap { $0.id }

        // Prepare query to see if tasks are already added
        var query = OCKTaskQuery(for: Date())
        query.ids = taskIdsToAdd

        let foundTasks = try await fetchTasks(query: query)
        var tasksNotInStore = [OCKTask]()

        // Check results to see if there's a missing task
        tasks.forEach { potentialTask in
            if foundTasks.first(where: { $0.id == potentialTask.id }) == nil {
                tasksNotInStore.append(potentialTask)
            }
        }

        // Only add if there's a new task
        if tasksNotInStore.count > 0 {
            do {
                _ = try await addTasks(tasksNotInStore)
                Logger.ockStore.info("Added tasks into OCKStore!")
            } catch {
                Logger.ockStore.error("Error adding tasks: \(error.localizedDescription)")
            }
        }
    }

    func populateCarePlans(patientUUID: UUID? = nil) async throws {
        let checkInCarePlan = OCKCarePlan(id: CarePlanID.checkIn.rawValue,
                                          title: "Check in Care Plan",
                                          patientUUID: patientUUID)

        let socialCarePlan = OCKCarePlan(id: CarePlanID.social.rawValue,
                                          title: "Get More Social",
                                          patientUUID: patientUUID)
        let strengthCarePlan = OCKCarePlan(id: CarePlanID.stronger.rawValue,
                                          title: "Get More Sttronger",
                                          patientUUID: patientUUID)
        try await AppDelegateKey
            .defaultValue?
            .storeManager
            .addCarePlansIfNotPresent([checkInCarePlan, socialCarePlan, strengthCarePlan],
                                      patientUUID: patientUUID)
    }

    @MainActor
    class func getCarePlanUUIDs() async throws -> [CarePlanID: UUID] {
        var results = [CarePlanID: UUID]()

        guard let store = AppDelegateKey.defaultValue?.store else {
            return results
        }

        var query = OCKCarePlanQuery(for: Date())
        query.ids = [CarePlanID.health.rawValue,
                     CarePlanID.checkIn.rawValue, CarePlanID.social.rawValue, CarePlanID.stronger.rawValue]

        let foundCarePlans = try await store.fetchCarePlans(query: query)
        // Populate the dictionary for all CarePlan's
        CarePlanID.allCases.forEach { carePlanID in
            results[carePlanID] = foundCarePlans
                .first(where: { $0.id == carePlanID.rawValue })?.uuid
        }
        return results
    }

    func addContactsIfNotPresent(_ contacts: [OCKContact]) async throws {
        let contactIdsToAdd = contacts.compactMap { $0.id }

        // Prepare query to see if contacts are already added
        var query = OCKContactQuery(for: Date())
        query.ids = contactIdsToAdd

        let foundContacts = try await fetchContacts(query: query)
        var contactsNotInStore = [OCKContact]()

        // Check results to see if there's a missing task
        contacts.forEach { potential in
            if foundContacts.first(where: { $0.id == potential.id }) == nil {
                contactsNotInStore.append(potential)
            }
        }

        // Only add if there's a new task
        if contactsNotInStore.count > 0 {
            do {
                _ = try await addContacts(contactsNotInStore)
                Logger.ockStore.info("Added contacts into OCKStore!")
            } catch {
                Logger.ockStore.error("Error adding contacts: \(error.localizedDescription)")
            }
        }
    }

    // Adds tasks and contacts into the store
    func populateSampleData(_ patientUUID: UUID? = nil) async throws {
        try await populateCarePlans(patientUUID: patientUUID)
        let carePlanUUIDs = try await Self.getCarePlanUUIDs()

        let thisMorning = Calendar.current.startOfDay(for: Date())
        let aFewDaysAgo = Calendar.current.date(byAdding: .day, value: -4, to: thisMorning)!
        let before = Calendar.current.date(byAdding: .hour, value: 12, to: aFewDaysAgo)!
        let after = Calendar.current.date(byAdding: .hour, value: 24, to: aFewDaysAgo)!

        let schedule = OCKSchedule(composing: [
            OCKScheduleElement(start: before, end: nil,
                               interval: DateComponents(day: 1)),

            OCKScheduleElement(start: after, end: nil,
                               interval: DateComponents(day: 2))
        ])

        var drinkProteinShake = OCKTask(id: TaskID.proteinShake, title: "Drink Protein shake",
                                 carePlanUUID: nil, schedule: schedule)
        drinkProteinShake.instructions = "Drink and Optimum Nutrition protein drink"
        drinkProteinShake.asset = "cup.and.saucer.fill"
        drinkProteinShake.carePlanUUID = carePlanUUIDs[CarePlanID.stronger]
        // swiftlint:disable:next line_length
        drinkProteinShake.userInfo = [Constants.viewTypeKey: ViewType.checklist.rawValue, Constants.plotTypeKey: PlotType.bar.rawValue]

        let loudVoiceSchedule = OCKSchedule(composing: [
            OCKScheduleElement(start: before, end: nil, interval: DateComponents(day: 1),
                               text: "Anytime throughout the day", targetValues: [], duration: .allDay)
        ])

        var loudVoice = OCKTask(id: TaskID.loudVoice, title: "Track when you speak too loudly",
                             carePlanUUID: nil, schedule: loudVoiceSchedule)
        loudVoice.impactsAdherence = false
        loudVoice.instructions = "Tap the button anytime I talk over someone."
        loudVoice.asset = "mouth.fill"
        loudVoice.carePlanUUID = carePlanUUIDs[CarePlanID.social]
        // swiftlint:disable:next line_length
        loudVoice.userInfo = [Constants.viewTypeKey: ViewType.buttonLog.rawValue, Constants.plotTypeKey: PlotType.bar.rawValue]

        var repetitionPositive = OCKTask(id: TaskID.repetition,
                                 title: "Track your positive affrimations",
                                 carePlanUUID: nil,
                                 schedule: loudVoiceSchedule)
        repetitionPositive.impactsAdherence = false
        repetitionPositive.instructions = "Input your positive speaking score"
        repetitionPositive.asset = "repeat.circle"
        repetitionPositive.carePlanUUID = carePlanUUIDs[CarePlanID.social]
        // swiftlint:disable:next line_length
        repetitionPositive.userInfo = [Constants.viewTypeKey: ViewType.counter.rawValue, Constants.plotTypeKey: PlotType.bar.rawValue]

        var repetitionMood = OCKTask(id: TaskID.repetitionMood,
                                 title: "Track your mood",
                                 carePlanUUID: nil,
                                 schedule: loudVoiceSchedule)
        repetitionMood.impactsAdherence = false
        repetitionMood.instructions = "Type how you are feeling"
        repetitionMood.asset = "repeat.circle"
        repetitionMood.carePlanUUID = carePlanUUIDs[CarePlanID.social]
        // swiftlint:disable:next line_length
        repetitionMood.userInfo = [Constants.viewTypeKey: ViewType.logger.rawValue, Constants.plotTypeKey: PlotType.bar.rawValue]

        let sayHiElement = OCKScheduleElement(start: Date(), end: nil, interval: DateComponents(day: 1))
        let sayHiSchedule = OCKSchedule(composing: [sayHiElement])
        // swiftlint:disable:next line_length
        var sayHi = OCKTask(id: TaskID.sayHi, title: "Say hi to three people daily", carePlanUUID: nil, schedule: sayHiSchedule)
        sayHi.impactsAdherence = true
        sayHi.instructions = "Say hi"
        sayHi.carePlanUUID = carePlanUUIDs[CarePlanID.social]
        // swiftlint:disable:next line_length
        sayHi.userInfo = [Constants.viewTypeKey: ViewType.simpleTaskView.rawValue, Constants.plotTypeKey: PlotType.line.rawValue]

        let pushupElement = OCKScheduleElement(start: before, end: nil, interval: DateComponents(day: 1))
        let pushupSchedule = OCKSchedule(composing: [pushupElement])
        var pushup = OCKTask(id: TaskID.pushup, title: "Pushup", carePlanUUID: nil, schedule: pushupSchedule)
        pushup.impactsAdherence = true
        pushup.asset = "figure.walk"
        pushup.carePlanUUID = carePlanUUIDs[CarePlanID.stronger]
        // swiftlint:disable:next line_length
        pushup.userInfo = [Constants.viewTypeKey: ViewType.instructionsTaskView.rawValue, Constants.plotTypeKey: PlotType.scatter.rawValue]

        // swiftlint:disable:next line_length
        try await addTasksIfNotPresent([loudVoice, drinkProteinShake, sayHi, pushup, repetitionPositive, repetitionMood])
        try await addOnboardTask(carePlanUUIDs[.health])
        try await addSurveyTasks(carePlanUUIDs[.checkIn])

//        guard User.current != nil,
//              let personUUIDString = try? Utility.getRemoteClockUUID().uuidString else {
//            Logger.myContact.error("User not logged in")
//            return
//        }

        var contact1 = OCKContact(id: "jane", givenName: "Jane",
                                  familyName: "Daniels", carePlanUUID: nil)
        contact1.asset = "JaneDaniels"
        contact1.title = "Family Practice Doctor"
        contact1.role = "Dr. Daniels is a family practice doctor with 8 years of experience."
        contact1.emailAddresses = [OCKLabeledValue(label: CNLabelEmailiCloud, value: "janedaniels@uky.edu")]
        contact1.phoneNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(859) 257-2000")]
        contact1.messagingNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(859) 357-2040")]
//        contact1.remoteID = personUUIDString
        contact1.address = {
            let address = OCKPostalAddress()
            address.street = "2195 Harrodsburg Rd"
            address.city = "Lexington"
            address.state = "KY"
            address.postalCode = "40504"
            return address
        }()

        var contact2 = OCKContact(id: "matthew", givenName: "Matthew",
                                  familyName: "Reiff", carePlanUUID: nil)
        contact2.asset = "MatthewReiff"
        contact2.title = "OBGYN"
        contact2.role = "Dr. Reiff is an OBGYN with 13 years of experience."
        contact2.phoneNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(859) 257-1000")]
        contact2.messagingNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(859) 257-1234")]
//        contact2.remoteID = personUUIDString
        contact2.address = {
            let address = OCKPostalAddress()
            address.street = "1000 S Limestone"
            address.city = "Lexington"
            address.state = "KY"
            address.postalCode = "40536"
            return address
        }()

        try await addContactsIfNotPresent([contact1, contact2])
    }

    func addOnboardTask(_ carePlanUUID: UUID? = nil) async throws {
        let onboardSchedule = OCKSchedule.dailyAtTime(
            hour: 0, minutes: 0,
            start: Date(), end: nil,
            text: "Task Due!",
            duration: .allDay
        )

        var onboardTask = OCKTask(
            id: Onboard.identifier(),
            title: "Onboard",
            carePlanUUID: carePlanUUID,
            schedule: onboardSchedule
        )
        onboardTask.instructions = "You'll need to agree to some terms and conditions before we get started!"
        onboardTask.impactsAdherence = false
        onboardTask.userInfo = [Constants.viewTypeKey: ViewType.survey.rawValue]
        onboardTask.survey = .onboard

        try await addTasksIfNotPresent([onboardTask])
    }

    func addSurveyTasks(_ carePlanUUID: UUID? = nil) async throws {
        let checkInSchedule = OCKSchedule.dailyAtTime(
            hour: 8, minutes: 0,
            start: Date(), end: nil,
            text: nil
        )

        var checkInTask = OCKTask(
            id: CheckIn.identifier(),
            title: "Check In",
            carePlanUUID: carePlanUUID,
            schedule: checkInSchedule
        )
        checkInTask.instructions = "Check In with Track"
        checkInTask.userInfo = [Constants.viewTypeKey: ViewType.survey.rawValue]
        checkInTask.survey = .checkIn

        let thisMorning = Calendar.current.startOfDay(for: Date())

//        let nextWeek = Calendar.current.date(
//            byAdding: .weekOfYear,
//            value: 1,
//            to: Date()
//        )!

        let nextMonth = Calendar.current.date(
            byAdding: .month,
            value: 1,
            to: thisMorning
        )

//        let dailyElement = OCKScheduleElement(
//            start: thisMorning,
//            end: nextWeek,
//            interval: DateComponents(day: 1),
//            text: nil,
//            targetValues: [],
//            duration: .allDay
//        )

        let weeklyElement = OCKScheduleElement(
            start: thisMorning,
            end: nextMonth,
            interval: DateComponents(weekOfYear: 1),
            text: nil,
            targetValues: [],
            duration: .allDay
        )

        let motivateSchedule = OCKSchedule(
            composing: [weeklyElement]
        )

        var motivateTask = OCKTask(
            id: Motivate.identifier(),
            title: "Get on Track",
            carePlanUUID: carePlanUUID,
            schedule: motivateSchedule
        )
        motivateTask.userInfo = [Constants.viewTypeKey: ViewType.survey.rawValue]
        motivateTask.survey = .motivate

        try await addTasksIfNotPresent([checkInTask, motivateTask])
    }
}
