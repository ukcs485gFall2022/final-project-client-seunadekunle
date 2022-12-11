//
//  CustomCardViewModel.swift
//  OCKSample
//
//  Created by Corey Baker on 12/3/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//
import CareKit
import CareKitStore
import Foundation

class CounterCardViewModel: CardViewModel {
    /*
     TDO: Place any additional properties needed for your custom Card.
     Be sure to @Published them if they update your view
     */

    /// Example value
    @Published var value: Int = 0

    let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.zeroSymbol = ""
        return formatter
    }()

    /// This value can be used directly in Text() views.
    var valueForButton: String {
        let intVal = taskEvents.firstEventOutcomeValueInt
        return "\(Int(intVal))"
    }

    /// Action performed when button is tapped
    private(set) var action: (Int) async -> Void = { _ in
    }

    func increment() {
        self.value += 1
    }

    func decrement() {
        if self.value > 0 {
            self.value -= 1}
    }

    /// Create an instance for the default content. The first event that matches the
    /// provided query will be fetched from the the store and
    /// published to the view. The view will update when changes occur in the store.
    /// - Parameters:
    ///     - taskID: The ID of the task to fetch.
    ///     - eventQuery: A query used to fetch an event in the store.
    ///     - storeManager: Wraps the store that contains the event to fetch.
    convenience init(taskID: String,
                     eventQuery: OCKEventQuery,
                     storeManager: OCKSynchronizedStoreManager) {
        self.init(storeManager: storeManager)
        setQuery(.taskIDs([taskID], eventQuery))
        self.query?.perform(using: self)
    }

    /// Create an instance for the default content. The first event that matches the
    /// provided query will be fetched from the the store and
    /// published to the view. The view will update when changes occur in the store.
    /// - Parameters:
    ///     - task: The task associated with the event to fetch.
    ///     - eventQuery: A query used to fetch an event in the store.
    ///     - storeManager: Wraps the store that contains the event to fetch.
    convenience init(task: OCKAnyTask,
                     eventQuery: OCKEventQuery,
                     storeManager: OCKSynchronizedStoreManager) {
        self.init(storeManager: storeManager)
        setQuery(.tasks([task], eventQuery))
        self.action = { value in
            do {
                if self.taskEvents.firstEventOutcomeValues != nil {
                    _ = try await self.appendOutcomeValue(value: value,
                                                          at: .init(row: 0, section: 0))
                } else {
                    _ = try await self.saveOutcomesForEvent(atIndexPath: .init(row: 0, section: 0),
                                                            values: [.init(value)])
                }
            } catch {
                self.actionError = error
            }
        }
        self.query?.perform(using: self)
    }

    /// Automatically updates the value after it's saved to the database.
    @MainActor
    func checkIfValueShouldUpdate(_ updatedEvents: OCKTaskEvents) {
        let changedValue = updatedEvents.firstEventOutcomeValueInt

        if self.value != changedValue {
            self.value = changedValue
        }
    }
}
