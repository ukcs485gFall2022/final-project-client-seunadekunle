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

}
