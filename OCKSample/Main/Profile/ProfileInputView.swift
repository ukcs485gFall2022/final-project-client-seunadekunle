//
//  ProfileInputView.swift
//  OCKSample
//
//  Created by seun on 11/14/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI
import CareKitStore

struct ProfileInputView: View {
    @ObservedObject var viewModel: ProfileViewModel

    let colorStyler = ColorStyler()
    let appearanceStyler = AppearanceStyler()
    let dimensionStyler = DimensionStyler()

    var body: some View {
        Section("About") {
            TextField("First Name", text: $viewModel.firstName)
                .padding()
                .background(colorStyler.convertToColor(color: colorStyler.customBackground))
                .cornerRadius(appearanceStyler.cornerRadius1)
                .listRowSeparator(.hidden)

            TextField("Last Name", text: $viewModel.lastName)
                .padding()
                .background(colorStyler.convertToColor(color: colorStyler.customBackground))
                .cornerRadius(appearanceStyler.cornerRadius1)
                .listRowSeparator(.hidden)

            TextField("Notes", text: $viewModel.note)
                .padding()
                .background(colorStyler.convertToColor(color: colorStyler.customBackground))
                .cornerRadius(appearanceStyler.cornerRadius1)
                .listRowSeparator(.hidden)

            DatePicker("Birthday", selection: $viewModel.birthday,
                displayedComponents: [DatePickerComponents.date])
                .cornerRadius(appearanceStyler.cornerRadius1)
                .listRowSeparator(.hidden)

            TextField("Allergy", text: $viewModel.allergy)
                .padding()
                .background(colorStyler.convertToColor(color: colorStyler.customBackground))
                .cornerRadius(appearanceStyler.cornerRadius1)
                .listRowSeparator(.hidden)

        }

        Picker(selection: $viewModel.sex,
            label: Text("Sex")) {
            Text(OCKBiologicalSex.female.rawValue).tag(OCKBiologicalSex.female)
            Text(OCKBiologicalSex.male.rawValue).tag(OCKBiologicalSex.male)
            Text("Other").tag(OCKBiologicalSex.other(viewModel.sexOtherField))
        }

        Section("Address") {
            TextField("Street", text: $viewModel.street)
                .padding()
                .background(colorStyler.convertToColor(color: colorStyler.customBackground))
                .cornerRadius(appearanceStyler.cornerRadius1)
                .listRowSeparator(.hidden)

            TextField("City", text: $viewModel.city)
                .padding()
                .background(colorStyler.convertToColor(color: colorStyler.customBackground))
                .cornerRadius(appearanceStyler.cornerRadius1)
                .listRowSeparator(.hidden)

            TextField("State", text: $viewModel.state)
                .padding()
                .background(colorStyler.convertToColor(color: colorStyler.customBackground))
                .cornerRadius(appearanceStyler.cornerRadius1)
                .listRowSeparator(.hidden)

            TextField("Postal Code", text: $viewModel.zipcode)
                .keyboardType(.numberPad)
                .padding()
                .background(colorStyler.convertToColor(color: colorStyler.customBackground))
                .cornerRadius(appearanceStyler.cornerRadius1)
                .listRowSeparator(.hidden)
        }

        Section("Contact") {
            TextField("Email", text: $viewModel.emailAddress)
                .keyboardType(.phonePad)
                .padding()
                .background(colorStyler.convertToColor(color: colorStyler.customBackground))
                .cornerRadius(appearanceStyler.cornerRadius1)
                .listRowSeparator(.hidden)

            TextField("Message Number", text: $viewModel.messagingNumber)
                .keyboardType(.phonePad)
                .padding()
                .background(colorStyler.convertToColor(color: colorStyler.customBackground))
                .cornerRadius(appearanceStyler.cornerRadius1)
                .listRowSeparator(.hidden)

            TextField("Phone Numbers", text: $viewModel.phoneNumber)
                .keyboardType(.phonePad)
                .padding()
                .background(colorStyler.convertToColor(color: colorStyler.customBackground))
                .cornerRadius(appearanceStyler.cornerRadius1)
                .listRowSeparator(.hidden)

            TextField("Contact info", text: $viewModel.otherContactInfo)
                .padding()
                .background(colorStyler.convertToColor(color: colorStyler.customBackground))
                .cornerRadius(appearanceStyler.cornerRadius1)
                .listRowSeparator(.hidden)
        }

    }
}

struct ProfileInputView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileInputView(viewModel: .init())
    }
}
