//
//  CareViewModel.swift
//  OCKSample
//
//  Created by seun on 12/12/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import SwiftUI
import CareKit
import CareKitUI
import CareKitStore
import HealthKit
import ParseCareKit
import ParseSwift
import os.log

class CareViewModel: ObservableObject {

    init() {
        reloadViewModel()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadViewModel(_:)),
                                               name: Notification.Name(rawValue: Constants.shouldRefreshView),
                                               object: nil)
    }

    @objc private func reloadViewModel(_ notification: Notification? = nil) {
        Task {
            _ = await findAndObserveCurrentProfile()
        }
    }

    @MainActor
    private func findAndObserveCurrentProfile() async {
        guard let uuid = try? Utility.getRemoteClockUUID() else {
            Logger.careViewModel.error("Could not get remote uuid for this user.")
            return
        }

        do {
            try await fetchProfilePicture()
        } catch {
            Logger.careViewModel.error("Could not fetch profile image: \(error)")
        }
    }

    @MainActor
    private func fetchProfilePicture() async throws {

        guard let currentUser = try await User.current?.fetch() else {
            Logger.careViewModel.error("User is not logged in")
            return
        }

        if let trackScore = currentUser.trackScore {

            // Download trackscore if needed
            self.trackScore = trackScore
        }

    }

    @Published var trackScore = 0 {
        willSet {

            Task {
                guard var currentUser = User.current else {
                    Logger.careViewModel.error("User is not logged in")
                    return
                }

                // Use `.set()` to update ParseObject's that have already been saved before
                currentUser = currentUser.set(\.trackScore, to: newValue)
                do {
                    _ = try await currentUser.save()
                    Logger.careViewModel.info("Saved updated profile picture successfully.")
                } catch {
                    Logger.careViewModel.error("Could not save profile picture: \(error.localizedDescription)")
                }
            }
        }
    }

}
