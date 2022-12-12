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
    
    /// reload ViewModel to reflect changes in the view
    /// - Parameter notification: notification object passed by NotificationCenter
    @objc private func reloadViewModel(_ notification: Notification? = nil) {
        Task {
            _ = await findAndObserveCurrentUser()
        }
    }

    @MainActor
    /// observer function
    private func findAndObserveCurrentUser() async {

        do {
            try await fetchTrackScore()
        } catch {
            Logger.careViewModel.error("Could not fetch track score: \(error)")
        }
    }

    @MainActor
    /// fetches trackScore from Parse database to update published variable
    private func fetchTrackScore() async throws {

        guard let currentUser = try await User.current?.fetch() else {
            Logger.careViewModel.error("User is not logged in")
            return
        }

        if let trackScore = currentUser.trackScore {

            // get trackscore if needed
            self.trackScore = trackScore
        }

    }
    
    /// trackScore variable that saves to database when changed
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
