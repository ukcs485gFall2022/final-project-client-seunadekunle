//
//  NewPlanView.swift
//  OCKSample
//
//  Created by seun on 11/15/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI
import CareKit
import CareKitUI
import CareKitStore

struct NewPlanView: View {
    @Environment(\.presentationMode) var presentationMode

    @StateObject var viewModel: NewPlanViewModel
    let colorStyler = ColorStyler()
    let appearanceStyler = AppearanceStyler()
    let dimensionStyler = DimensionStyler()

    @State private var plans: [OCKCarePlan] = []

    var body: some View {
        VStack(alignment: .leading) {

            NavigationView {
                Form {
                    TextField("Title", text: $viewModel.title)
                        .padding()
                        .background(ColorStyler.convertToColor(color: colorStyler.customBackground))
                        .cornerRadius(appearanceStyler.cornerRadius1)
                        .listRowSeparator(.hidden)
                    Section("Added Care Plans") {
                        List(plans) { value in
                            HStack(alignment: .center) {
                                Text("\(value.title)")
                            }.listRowSeparator(.hidden)
                                .padding(10)
                                .cornerRadius(appearanceStyler.cornerRadius1)
                                .background(ColorStyler.convertToColor(color: ColorStyler.iconBlue))
                                .foregroundColor(ColorStyler.convertToColor(color: ColorStyler.iconYellow))
                                .cornerRadius(appearanceStyler.cornerRadius1)
                                .frame(width: dimensionStyler.screenWidth / 0.9)
                        } .scrollContentBackground(.hidden)
                            .padding(EdgeInsets(top: 0,
                                                leading: 0,
                                                bottom: 0,
                                                trailing: 0))
                    }

                }
                .navigationBarTitle("Add Plan")
                .scrollDisabled(false)
                .background(.white)
                .scrollContentBackground(.hidden)
            }
        }
        .frame(height: dimensionStyler.screenHeight / 3)
        .scrollContentBackground(.hidden)
        .onReceive(viewModel.$carePlans) { value in
            plans = value
        }

        Button(action: {
            Task {
                try await viewModel.addCarePlan()
                self.presentationMode.wrappedValue.dismiss()
            }

        }, label: {
            Spacer()
            Text("Add Plan")
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

struct NewPlanView_Previews: PreviewProvider {
    static var previews: some View {
        NewPlanView(viewModel: .init())
    }
}
