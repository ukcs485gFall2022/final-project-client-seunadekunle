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
    @StateObject var viewModel: NewGoalsViewModel
    let colorStyler = ColorStyler()
    let appearanceStyler = AppearanceStyler()
    let dimensionStyler = DimensionStyler()

    @State private var freq = "Daily"
    let freqTypes = ["Daily", "Weekly", "Monthly"]

    @State private var taskType = "Normal"
    let ockTaskTypes = ["Normal", "Health"]

    @State private var healthTask = "Counting Sugar"
    let healthTaskList = ["Counting Sugar", "Water intake", "Protein", "Flights Climbed"]

    var body: some View {

        VStack(alignment: .leading) {

            HStack {
                Text("Add habit")
                    .font(.largeTitle)
                    .foregroundColor(.black)
                    .fontWeight(.semibold)
                    .padding(EdgeInsets(top: 0,
                    leading: dimensionStyler.sidePadding,
                    bottom: dimensionStyler.sidePadding * 2,
                    trailing: dimensionStyler.sidePadding + 17))

                Picker("Select the type", selection: $taskType) {
                    ForEach(ockTaskTypes, id: \.self) {
                        Text($0)
                    }
                }
                    .pickerStyle(.menu)
                    .padding(EdgeInsets(top: 0,
                    leading: dimensionStyler.sidePadding,
                    bottom: dimensionStyler.sidePadding * 2,
                    trailing: dimensionStyler.sidePadding))

            }

            TextField("Title", text: $viewModel.title)
                .padding()
                .background(colorStyler.convertToColor(color: colorStyler.customBackground))
                .cornerRadius(appearanceStyler.cornerRadius1)
                .padding(EdgeInsets(top: -40,
                leading: dimensionStyler.sidePadding,
                bottom: dimensionStyler.sidePadding * 2,
                trailing: dimensionStyler.sidePadding))

            TextField("Instructions", text: $viewModel.instructions)
                .padding()
                .background(colorStyler.convertToColor(color: colorStyler.customBackground))
                .cornerRadius(appearanceStyler.cornerRadius1)
                .padding(EdgeInsets(top: -40,
                leading: dimensionStyler.sidePadding,
                bottom: dimensionStyler.sidePadding * 2,
                trailing: dimensionStyler.sidePadding))

            HStack {
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

                switch taskType {
                case "Health":
                    Picker("Select the Health Task", selection: $healthTask) {
                        ForEach(healthTaskList, id: \.self) {
                            Text($0)
                        }
                    }
                        .pickerStyle(.menu)
                        .padding(EdgeInsets(top: -40,
                        leading: dimensionStyler.sidePadding,
                        bottom: dimensionStyler.sidePadding * 2,
                        trailing: dimensionStyler.sidePadding))
                default:
                    EmptyView()
                }
            }

            Text("Schedule")
                .font(.headline)
                .foregroundColor(colorStyler.convertToColor(color: colorStyler.iconYellow
                ))
                .fontWeight(.medium)
                .padding(EdgeInsets(top: 0,
                leading: dimensionStyler.sidePadding * 1.5,
                bottom: 0,
                trailing: dimensionStyler.sidePadding))

            DatePicker("Start date", selection: $viewModel.start, displayedComponents: [DatePickerComponents.date])
                .padding()
                .cornerRadius(appearanceStyler.cornerRadius1)
                .padding(EdgeInsets(top: 0,
                leading: dimensionStyler.sidePadding,
                bottom: 0,
                trailing: dimensionStyler.sidePadding))

            DatePicker("End date", selection: $viewModel.end, displayedComponents: [DatePickerComponents.date])
                .padding()
                .cornerRadius(appearanceStyler.cornerRadius1)
                .padding(EdgeInsets(top: 0,
                leading: dimensionStyler.sidePadding,
                bottom: 0,
                trailing: dimensionStyler.sidePadding))

            Button(action: {
                Task {
                    switch taskType {
                    case "Health":
                        viewModel.taskID = TaskID.healthSugar
                        await viewModel.addTask(freq: freq, taskType: taskType, healthTask: healthTask)
                    default:
                        viewModel.taskID = TaskID.defaultTask
                        await viewModel.addTask(freq: freq, taskType: taskType)
                    }

                    self.presentationMode.wrappedValue.dismiss()
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
