//
//  NewPlanViewModel.swift
//  OCKSample
//
//  Created by seun on 11/1/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
let uuid = UUID().uuidString

import SwiftUI
import CareKit
import CareKitUI
import CareKitStore
import HealthKit
import os.log

class NewPlanViewModel: ObservableObject {

    @Published var error: AppError?
    @Published public var title = ""
    @Published public var carePlans = [OCKCarePlan(id: UUID().uuidString,
        title: "Check in Care Plan",
        patientUUID: nil)]

    init() {
        Task {
            await queryCarePlans()
        }
    }

    func addCarePlan() async throws {

        let patientQuery = OCKPatientQuery(for: Date())

        let patients = try await AppDelegateKey.defaultValue?.store?.fetchPatients(query: patientQuery)
        guard let patient = patients?.last as? OCKPatient else {
            throw AppError.couldntCast
        }

        let newPlan = OCKCarePlan(id: UUID().uuidString,
            title: title,
            patientUUID: patient.uuid)

        try await AppDelegateKey
            .defaultValue?
            .storeManager.addCarePlansIfNotPresent([newPlan], patientUUID: patient.uuid)
    }

    func queryCarePlans() async {

        do {
            guard let appDelegate = AppDelegateKey.defaultValue else {
                self.error = AppError.couldntBeUnwrapped
                self.carePlans = []
                return
            }

            let query = OCKCarePlanQuery()
            if let queriedPlans = try await appDelegate.store?.fetchCarePlans(query: query) {
                // runs on main thread
                DispatchQueue.main.async {
                    self.carePlans = queriedPlans
                }
            }

        } catch {
            Logger.newPlanView.error("Can't get error: \(error)")
        }

    }

}
