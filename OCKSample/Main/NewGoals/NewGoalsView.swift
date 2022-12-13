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
    let freqTypes = ["Daily", "Hourly", "Weekly", "Monthly"]

    @State private var healthTask = "Counting Sugar"
    let healthTaskList = ["Counting Sugar", "Water intake", "Protein", "Flights Climbed"]

    @State private var taskAsset = "figure.stairs"
    let assets = ["drop.fill", "fork.knife", "heart.fill", "figure.stairs",
                  "figure.gymnastics", "figure.american.football", "figure.basketball"]

    @State private var selectedColorIndex = 0 // <1>

    var body: some View {
        VStack(alignment: .leading) {

            NavigationView {
                Form {

                    NewGoalsTopView(viewModel: viewModel)

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

                        switch viewModel.taskType {
                        case "Health":
                            Picker("Select the Health Type", selection: $healthTask) {
                                ForEach(healthTaskList, id: \.self) {
                                    Text($0)
                                }
                            }
                            .foregroundColor(ColorStyler.convertToColor(color: .black))
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
                            ForEach(0..<7) { ind in
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

                    Picker("Select the plot type", selection: $viewModel.plotType) {
                        ForEach(PlotType.allCases, id: \.self) { val in
                            Text(val.id)
                        }
                    }.pickerStyle(.navigationLink)

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
            } .alert(isPresented: $viewModel.isShowingAddAlert) {
                return Alert(title: Text("Update"),
                             message: Text(viewModel.alertMessage),
                             dismissButton: .default(Text("Ok"), action: {
                    viewModel.isShowingAddAlert = false
                }))
            }

        }
        Button(action: {
            Task {
                switch viewModel.taskType {
                case "Health":
                    await viewModel.addTask(freq: freq, newAssetName: taskAsset, healthTask: healthTask)
                default:
                    await viewModel.addTask(freq: freq, newAssetName: taskAsset)
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
        .background(ColorStyler.convertToColor(color: ColorStyler.iconBlue))
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
