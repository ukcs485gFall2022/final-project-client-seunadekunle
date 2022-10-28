//
//  NewGoalsView.swift
//  OCKSample
//
//  Created by seun on 10/26/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI
import CareKitUI
import CareKitStore
import CareKit
import os.log

struct NewGoalsView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var showSheet = false
    @State var title = ""
    @State var instructions = ""
    @State var startDate = Date()
    @State var endDate = Date()
    @StateObject var viewModel: NewGoalsViewModel
    let colorStyler = ColorStyler()
    let appearanceStyler = AppearanceStyler()
    let dimensionStyler = DimensionStyler()

    @State private var freq = "Daily"
    let freqTypes = ["Daily", "Weekly", "Monthly"]

    @State private var taskID = TaskID.multistep
    let taskTypes = ["Weekly", "Monthly"]

    var body: some View {

        VStack(alignment: .leading) {

            Text("Add habit")
                .font(.largeTitle)
                .foregroundColor(.black)
                .fontWeight(.semibold)
                .padding(EdgeInsets(top: 0,
                leading: dimensionStyler.sidePadding,
                bottom: dimensionStyler.sidePadding * 2,
                trailing: dimensionStyler.sidePadding + 17))

            TextField("Title", text: $title)
                .padding()
                .background(colorStyler.convertToColor(color: colorStyler.customBackground))
                .cornerRadius(appearanceStyler.cornerRadius1)
                .padding(EdgeInsets(top: -40,
                leading: dimensionStyler.sidePadding,
                bottom: dimensionStyler.sidePadding * 2,
                trailing: dimensionStyler.sidePadding))

            TextField("Instructions", text: $instructions)
                .padding()
                .background(colorStyler.convertToColor(color: colorStyler.customBackground))
                .cornerRadius(appearanceStyler.cornerRadius1)
                .padding(EdgeInsets(top: -40,
                leading: dimensionStyler.sidePadding,
                bottom: dimensionStyler.sidePadding * 2,
                trailing: dimensionStyler.sidePadding))

            Picker("Select the frequency", selection: $freq) {
                ForEach(freqTypes, id: \.self) {
                    Text($0)
                }
            }
                .pickerStyle(.menu)
                .padding(EdgeInsets(top: -40,
                leading: dimensionStyler.sidePadding,
                bottom: dimensionStyler.sidePadding * 2,
                trailing: dimensionStyler.sidePadding))

            Text("Schedule")
                .font(.headline)
                .foregroundColor(colorStyler.convertToColor(color: colorStyler.iconYellow
                ))
                .fontWeight(.medium)
                .padding(EdgeInsets(top: 0,
                leading: dimensionStyler.sidePadding,
                bottom: 0,
                trailing: dimensionStyler.sidePadding))

            DatePicker("Start date", selection: $startDate, displayedComponents: [DatePickerComponents.date])
                .padding()
                .cornerRadius(appearanceStyler.cornerRadius1)
                .padding(EdgeInsets(top: 0,
                leading: dimensionStyler.sidePadding,
                bottom: 0,
                trailing: dimensionStyler.sidePadding))

            DatePicker("End date", selection: $endDate, displayedComponents: [DatePickerComponents.date])
                .padding()
                .cornerRadius(appearanceStyler.cornerRadius1)
                .padding(EdgeInsets(top: 0,
                leading: dimensionStyler.sidePadding,
                bottom: 0,
                trailing: dimensionStyler.sidePadding))

            Button(action: {
                Task {
//                    viewModel.instructions
                    // swiftlint:disable:next line_length
                    await viewModel.addTask(title: title, instructions: instructions, start: startDate, end: endDate, freq: freq, taskID: taskID)
//                    self.presentationMode.wrappedValue.dismiss()
                }

            }, label: {
                    Spacer()
                    Text("Add task")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                })
                .background(colorStyler.convertToColor(color: colorStyler.iconBlue))
                .cornerRadius(appearanceStyler.cornerRadius1)
                .padding(EdgeInsets(top: 0,
                leading: dimensionStyler.sidePadding + 17,
                bottom: dimensionStyler.sidePadding,
                trailing: dimensionStyler.sidePadding + 17))
        }.onReceive(viewModel.$error, perform: { error in
            print(error)
        })
    }
}

struct NewGoalsView_Previews: PreviewProvider {
    static var previews: some View {
        NewGoalsView(viewModel: .init())
    }
}
