//
//  Profile.swift
//  OCKSample
//
//  Created by Corey Baker on 11/25/20.
//  Copyright © 2020 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKit
import CareKitStore
import SwiftUI
import ParseCareKit
import os.log
import Combine
import ParseSwift

class ProfileViewModel: ObservableObject {
    // MARK: Public read, private write properties

    // Patient Variables
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var username = User.current?.username
    @Published var birthday = Date()
    @Published var sex: OCKBiologicalSex = .other("other")
    @Published var sexOtherField = "other"
    @Published var allergy = ""
    @Published var note = ""

    // Contact Variables
    @Published var street = ""
    @Published var city = ""
    @Published var state = ""
    @Published var zipcode = ""
    @Published var emailAddress = ""
    @Published var messagingNumber = ""
    @Published var phoneNumber = ""
    @Published var otherContactInfo = ""

    @Published var isShowingSaveAlert = false
    @Published var isPresentingAddTask = false
    @Published var isPresentingContact = false
    @Published var isPresentingImagePicker = false
    @Published var profileUIImage = UIImage(systemName: "person.fill") {
        willSet {
            guard self.profileUIImage != newValue,
                let inputImage = newValue else {
                return
            }

            if !isSettingProfilePictureForFirstTime {
                Task {
                    guard var currentUser = User.current,
                        let image = inputImage.jpegData(compressionQuality: 0.25) else {
                        Logger.profile.error("User is not logged in or could not compress image")
                        return
                    }

                    let newProfilePicture = ParseFile(name: "profile.jpg", data: image)
                    // Use `.set()` to update ParseObject's that have already been saved before.
                    currentUser = currentUser.set(\.profilePicture, to: newProfilePicture)
                    do {
                        _ = try await currentUser.save()
                        Logger.profile.info("Saved updated profile picture successfully.")
                    } catch {
                        Logger.profile.error("Could not save profile picture: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    @Published private(set) var error: Error?
    private(set) var storeManager: OCKSynchronizedStoreManager
    private(set) var alertMessage = "All changs saved successfully!"

    // MARK: Private read/write properties
    private var patient: OCKPatient? {
        willSet {
            if let currentFirstName = newValue?.name.givenName {
                firstName = currentFirstName
            } else {
                firstName = ""
            }
            if let currentLastName = newValue?.name.familyName {
                lastName = currentLastName
            } else {
                lastName = ""
            }
            if let currentBirthday = newValue?.birthday {
                birthday = currentBirthday
            } else {
                birthday = Date()
            }
            if let currentSex = newValue?.sex {
                sex = currentSex
            } else {
                sex = OCKBiologicalSex.male
            }
            if let currentAllergies = newValue?.allergies {
                allergy = currentAllergies[0]
            } else {
                allergy = ""
            }
        }
    }
    private var contact: OCKContact? {
        willSet {
            if let currentAddress = newValue?.address {
                street = currentAddress.street
                city = currentAddress.city
                state = currentAddress.state
                zipcode = currentAddress.postalCode
            } else {
                street = ""
                city = ""
                state = ""
                zipcode = ""
            }

            if let currentEmailAddresses  = newValue?.emailAddresses {
                emailAddress = currentEmailAddresses[0].value
            } else {
                emailAddress = ""
            }

            if let currentMessagingNumbers  = newValue?.messagingNumbers {
                messagingNumber = currentMessagingNumbers[0].value
            } else {
                messagingNumber = ""
            }

            if let currentPhoneNumbers = newValue?.phoneNumbers {
                phoneNumber = currentPhoneNumbers[0].value
            } else {
                phoneNumber = ""
            }

            if let currentContactInfo = newValue?.otherContactInfo {
                otherContactInfo = currentContactInfo[0].value
            } else {
                otherContactInfo = ""
            }
        }
    }
    private var isSettingProfilePictureForFirstTime = true
    private var cancellables: Set<AnyCancellable> = []

    init(storeManager: OCKSynchronizedStoreManager? = nil) {
        self.storeManager = storeManager ?? StoreManagerKey.defaultValue
        reloadViewModel()
        NotificationCenter.default.addObserver(self,
            selector: #selector(reloadViewModel(_:)),
            name: Notification.Name(rawValue: Constants.shouldRefreshView),
            object: nil)
    }
    // MARK: Helpers (private)
    private func clearSubscriptions() {
        cancellables = []
    }

    @objc private func reloadViewModel(_ notification: Notification? = nil) {
        Task {
            _ = await findAndObserveCurrentProfile()
            _ = await findAndObserveCurrentContact()
        }
    }

    @MainActor
    private func findAndObserveCurrentProfile() async {
        guard let uuid = try? Utility.getRemoteClockUUID() else {
            Logger.profile.error("Could not get remote uuid for this user.")
            return
        }
        clearSubscriptions()

        do {
            try await fetchProfilePicture()
        } catch {
            Logger.profile.error("Could not fetch profile image: \(error)")
        }

        // Build query to search for OCKPatient
        // swiftlint:disable:next line_length
        var queryForCurrentPatient = OCKPatientQuery(for: Date()) // This makes the query for the current version of Patient
        queryForCurrentPatient.ids = [uuid.uuidString] // Search for the current logged in user
        do {
            guard let appDelegate = AppDelegateKey.defaultValue,
                let foundPatient = try await appDelegate.store?.fetchPatients(query: queryForCurrentPatient),
                let currentPatient = foundPatient.first else {
                // swiftlint:disable:next line_length
                Logger.profile.error("Could not find patient with id \"\(uuid)\". It's possible they have never been saved.")
                return
            }
            self.observePatient(currentPatient)

            // Query the contact also so the user can edit
            var queryForCurrentContact = OCKContactQuery(for: Date())
            queryForCurrentContact.ids = [uuid.uuidString]
            guard let foundContact = try await appDelegate.store?.fetchContacts(query: queryForCurrentContact),
                let currentContact = foundContact.first else {
                // swiftlint:disable:next line_length
                Logger.profile.error("Error: Could not find contact with id \"\(uuid)\". It's possible they have never been saved.")
                return
            }
            self.observeContact(currentContact)
        } catch {
            // swiftlint:disable:next line_length
            Logger.profile.error("Could not find patient with id \"\(uuid)\". It's possible they have never been saved. Query error: \(error.localizedDescription)")
        }
    }

    @MainActor
    private func observePatient(_ patient: OCKPatient) {
        storeManager.publisher(forPatient: patient,
            categories: [.add, .update, .delete])
            .sink { [weak self] in
            self?.patient = $0 as? OCKPatient
        }
            .store(in: &cancellables)
    }

    @MainActor
    private func findAndObserveCurrentContact() async {
        guard let uuid = try? Utility.getRemoteClockUUID() else {
            Logger.profile.error("Could not get remote uuid for this user.")
            return
        }
        clearSubscriptions()

        // Build query to search for OCKPatient
        // swiftlint:disable:next line_length
        var queryForCurrentPatient = OCKPatientQuery(for: Date()) // This makes the query for the current version of Patient
        queryForCurrentPatient.ids = [uuid.uuidString] // Search for the current logged in user
        do {
            guard let appDelegate = AppDelegateKey.defaultValue,
                let foundPatient = try await appDelegate.store?.fetchPatients(query: queryForCurrentPatient),
                let currentPatient = foundPatient.first else {
                // swiftlint:disable:next line_length
                Logger.profile.error("Could not find patient with id \"\(uuid)\". It's possible they have never been saved.")
                return
            }
            self.observePatient(currentPatient)

            // Query the contact also so the user can edit
            var queryForCurrentContact = OCKContactQuery(for: Date())
            queryForCurrentContact.ids = [uuid.uuidString]
            guard let foundContact = try await appDelegate.store?.fetchContacts(query: queryForCurrentContact),
                let currentContact = foundContact.first else {
                // swiftlint:disable:next line_length
                Logger.profile.error("Error: Could not find contact with id \"\(uuid)\". It's possible they have never been saved.")
                return
            }
            self.observeContact(currentContact)

            try? await fetchProfilePicture()
        } catch {
            // swiftlint:disable:next line_length
            Logger.profile.error("Could not find patient with id \"\(uuid)\". It's possible they have never been saved. Query error: \(error.localizedDescription)")
        }
    }

    @MainActor
    private func observeContact(_ contact: OCKContact) {

        storeManager.publisher(forContact: contact,
            categories: [.add, .update, .delete])
            .sink { [weak self] in
            self?.contact = $0 as? OCKContact
        }
            .store(in: &cancellables)
    }

    @MainActor
    private func fetchProfilePicture() async throws {

        // Profile pics are stored in Parse User.
        guard let currentUser = try await User.current?.fetch() else {
            Logger.profile.error("User is not logged in")
            return
        }

        if let pictureFile = currentUser.profilePicture {

            // Download picture from server if needed
            do {
                let profilePicture = try await pictureFile.fetch()
                guard let path = profilePicture.localURL?.relativePath else {
                    Logger.profile.error("Could not find relative path for profile picture.")
                    return
                }
                self.profileUIImage = UIImage(contentsOfFile: path)
            } catch {
                Logger.profile.error("Could not fetch profile picture: \(error.localizedDescription).")
            }
        }
        self.isSettingProfilePictureForFirstTime = false
    }
}

extension ProfileViewModel {
    @MainActor
    func saveProfile() async {
        alertMessage = "All changs saved successfully!"
        do {
            try await savePatient()
            try await saveContact()
        } catch {
            alertMessage = "Could not save profile: \(error)"
        }
        isShowingSaveAlert = true // Make alert pop up for user.
    }

    private func updatePatient(_ patientToUpdate: inout OCKPatient) async throws {
        // If there is a currentPatient that was fetched, check to see if any of the fields changed
        var patientHasBeenUpdated = false

        if patient?.name.givenName != firstName {
            patientHasBeenUpdated = true
            patientToUpdate.name.givenName = firstName
        }

        if patient?.name.familyName != lastName {
            patientHasBeenUpdated = true
            patientToUpdate.name.familyName = lastName
        }

        if patient?.birthday != birthday {
            patientHasBeenUpdated = true
            patientToUpdate.birthday = birthday
        }

        if patient?.sex != sex {
            patientHasBeenUpdated = true
            patientToUpdate.sex = sex
        }

        let allergies = [allergy]
        if patient?.allergies != allergies {
            patientHasBeenUpdated = true
            patientToUpdate.allergies = allergies
        }

        let notes = [OCKNote(author: firstName,
                             title: "New Note",
                             content: note)]
        if patient?.notes != notes {
            patientHasBeenUpdated = true
            patientToUpdate.notes = notes
        }

        if patientHasBeenUpdated {

            let updated = try await storeManager.store.updateAnyPatient(patientToUpdate)
            Logger.profile.info("Successfully updated patient")
            guard let updatedPatient = updated as? OCKPatient else {
                Logger.profile.error("Could not cast to OCKPatient")
                return
            }
            self.patient = updatedPatient
        }
    }

    @MainActor
    func savePatient() async throws {
        if var patientToUpdate = patient {
            try await updatePatient(&patientToUpdate)

        } else {
            guard let remoteUUID = try? Utility.getRemoteClockUUID().uuidString else {
                Logger.profile.error("The user currently is not logged in")
                return
            }

            var newPatient = OCKPatient(id: remoteUUID,
                givenName: firstName,
                familyName: lastName)
            newPatient.birthday = birthday

            // This is new patient that has never been saved before
            let addedPatient = try await storeManager.store.addAnyPatient(newPatient)
            Logger.profile.info("Succesffully saved new patient")
            guard let addedOCKPatient = addedPatient as? OCKPatient else {
                Logger.profile.error("Could not cast to OCKPatient")
                return
            }
            self.patient = addedOCKPatient
            self.observePatient(addedOCKPatient)
        }
    }

    private func updateContact(_ contactToUpdate: inout OCKContact) async throws {
        // If a current contact was fetched, check to see if any of the fields have changed
        var contactHasBeenUpdated = false

        // Since OCKPatient was updated earlier, we should compare against this name
        if let patientName = patient?.name,
           contact?.name != patient?.name {
            contactHasBeenUpdated = true
            contactToUpdate.name = patientName
        }

        let emailAddresses = [OCKLabeledValue(label: "email", value: emailAddress)]
        if contact?.emailAddresses != emailAddresses {
            contactHasBeenUpdated = true
            contactToUpdate.emailAddresses = emailAddresses
        }

        let messagingNumbers = [OCKLabeledValue(label: "message", value: messagingNumber)]
        if contact?.messagingNumbers != messagingNumbers {
            contactHasBeenUpdated = true
            contactToUpdate.messagingNumbers = messagingNumbers
        }

        let phoneNumbers = [OCKLabeledValue(label: "phone", value: phoneNumber)]
        if contact?.phoneNumbers != phoneNumbers {
            contactHasBeenUpdated = true
            contactToUpdate.phoneNumbers = phoneNumbers
        }

        let otherContactInfos = [OCKLabeledValue(label: "other", value: otherContactInfo)]
        if contact?.otherContactInfo != otherContactInfos {
            contactHasBeenUpdated = true
            contactToUpdate.otherContactInfo = otherContactInfos
        }

        // Create a mutable temp address to compare
        let potentialAddress = OCKPostalAddress()
        potentialAddress.street = street
        potentialAddress.city = city
        potentialAddress.state = state
        potentialAddress.postalCode = zipcode

        if contact?.address != potentialAddress {
            contactHasBeenUpdated = true
            contactToUpdate.address = potentialAddress
        }

        if contactHasBeenUpdated {
            let updated = try await storeManager.store.updateAnyContact(contactToUpdate)
            Logger.profile.info("Successfully updated contact")
            guard let updatedContact = updated as? OCKContact else {
                Logger.profile.error("Could not cast to OCKContact")
                return
            }
            self.contact = updatedContact
        }
    }

    @MainActor
    func saveContact() async throws {

        if var contactToUpdate = contact {
            try await updateContact(&contactToUpdate)

        } else {

            guard let remoteUUID = try? Utility.getRemoteClockUUID().uuidString else {
                Logger.profile.error("The user currently is not logged in")
                return
            }

            guard let patientName = self.patient?.name else {
                Logger.profile.info("The patient did not have a name.")
                return
            }

            // Added code to create a contact for the respective signed up user
            let newContact = OCKContact(id: remoteUUID,
                name: patientName,
                carePlanUUID: nil)

            guard try await storeManager.store.addAnyContact(newContact) is OCKContact else {
                Logger.profile.error("Could not cast to OCKContact")
                return
            }

            self.contact = newContact
            self.observeContact(newContact)
        }

    }
}
