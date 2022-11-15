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

    @State private var taskAsset = "figure.stairs"

    let assets = ["drop.fill", "fork.knife", "heart.fill", "figure.stairs",
        "figure.gymnastics", "figure.american.football", "figure.basketball"]

    var body: some View {
        VStack(alignment: .leading) {

            NavigationView {
                Form {
                    Picker("Select the type", selection: $taskType) {
                        ForEach(ockTaskTypes, id: \.self) {
                            Text($0)
                        }
                    }
                        .foregroundColor(colorStyler.convertToColor(color: colorStyler.iconYellow))
                        .pickerStyle(.menu)

                    TextField("Title", text: $viewModel.title)
                        .padding()
                        .background(colorStyler.convertToColor(color: colorStyler.customBackground))
                        .cornerRadius(appearanceStyler.cornerRadius1)
                        .listRowSeparator(.hidden)

                    TextField("Instructions", text: $viewModel.instructions)
                        .padding()
                        .background(colorStyler.convertToColor(color: colorStyler.customBackground))
                        .cornerRadius(appearanceStyler.cornerRadius1)
                        .listRowSeparator(.hidden)

                    Picker("Select the Plan", selection: $viewModel.plan) {
                        ForEach(viewModel.plans, id: \.self) {
                            Text($0.title).tag($0.uuid)
                        }
                    }.listRowSeparator(.hidden)

                    VStack {
                        Picker("Select the frequency", selection: $freq) {
                            ForEach(freqTypes, id: \.self) {
                                Text($0)
                            }
                        }
                            .foregroundColor(.black)
                            .pickerStyle(.menu)
                            .listRowSeparator(.hidden)
                            .padding(EdgeInsets(top: 0,
                            leading: 0,
                            bottom: dimensionStyler.sidePadding / 5,
                            trailing: dimensionStyler.sidePadding))

                        switch taskType {
                        case "Health":
                            Picker("Select the Health Type", selection: $healthTask) {
                                ForEach(healthTaskList, id: \.self) {
                                    Text($0)
                                }
                            }
                                .foregroundColor(colorStyler.convertToColor(color: .black))
                                .pickerStyle(.menu)
                                .listRowSeparator(.hidden)
                                .padding(EdgeInsets(top: 0,
                                leading: 0,
                                bottom: dimensionStyler.sidePadding,
                                trailing: dimensionStyler.sidePadding))
                        default:
                            EmptyView()
                        }
                    }

                    // swiftlint:disable:next line_length
                    DatePicker("Start date", selection: $viewModel.start, displayedComponents: [DatePickerComponents.date])
                        .cornerRadius(appearanceStyler.cornerRadius1)
                        .listRowSeparator(.hidden)

                    DatePicker("End date", selection: $viewModel.end, displayedComponents: [DatePickerComponents.date])
                        .cornerRadius(appearanceStyler.cornerRadius1)
                        .listRowSeparator(.hidden)

                    HStack {
                        Text("Select Icon")
                            .font(.headline)
                            .foregroundColor(.black)
                            .fontWeight(.medium)
                            .padding(EdgeInsets(top: 0,
                            leading: 0,
                            bottom: 0,
                            trailing: dimensionStyler.sidePadding))

                        Text(taskAsset)
                            .font(.headline)
                            .foregroundColor(.black)
                            .fontWeight(.light)
                            .padding(EdgeInsets(top: 0,
                            leading: 0,
                            bottom: 0,
                            trailing: dimensionStyler.sidePadding))
                    }.padding(EdgeInsets(top: dimensionStyler.sidePadding / 1.5,
                        leading: 0,
                        bottom: 0,
                        trailing: dimensionStyler.sidePadding))
                        .listRowSeparator(.hidden)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(0..<assets.count) { ind in
                                Image(systemName: assets[ind])
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: dimensionStyler.splashIconSize / 4,
                                    height: dimensionStyler.splashIconSize / 4,
                                    alignment: .center) .onTapGesture {
                                    taskAsset = assets[ind]
                                }
                                Spacer(minLength: dimensionStyler.sidePadding)
                            }
                        }
                    }
                        .listRowSeparator(.hidden)

                    NavigationLink(destination: SelectViewType(viewType: $viewModel.viewType)) {
                        Label(viewModel.viewType.id, systemImage: "viewfinder")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    } .listRowSeparator(.hidden)

                }
                    .navigationBarTitle("Add Task")
                    .scrollDisabled(false)
                    .background(.white)
                    .scrollContentBackground(.hidden)
            }

        }
        Button(action: {
            Task {
                switch taskType {
                case "Health":
                    viewModel.taskID = TaskID.healthSugar
                    await viewModel.addTask(freq: freq, taskType: taskType,
                        newAssetName: taskAsset, healthTask: healthTask)
                default:
                    viewModel.taskID = TaskID.defaultTask
                    await viewModel.addTask(freq: freq, taskType: taskType, newAssetName: taskAsset)
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
            bottom: 0,
            trailing: dimensionStyler.sidePadding + 17))
    }
}

struct NewGoalsView_Previews: PreviewProvider {
    static var previews: some View {
        NewGoalsView(viewModel: .init())
    }
}
