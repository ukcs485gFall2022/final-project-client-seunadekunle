//
//  NewPlanView.swift
//  OCKSample
//
//  Created by seun on 11/15/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

struct NewPlanView: View {
    @Environment(\.presentationMode) var presentationMode

    @StateObject var viewModel: NewPlanViewModel
    let colorStyler = ColorStyler()
    let appearanceStyler = AppearanceStyler()
    let dimensionStyler = DimensionStyler()

    var body: some View {
        VStack(alignment: .leading) {

            NavigationView {
                Form {
                    TextField("Title", text: $viewModel.title)
                        .padding()
                        .background(ColorStyler.convertToColor(color: colorStyler.customBackground))
                        .cornerRadius(appearanceStyler.cornerRadius1)
                        .listRowSeparator(.hidden)
                }
                    .navigationBarTitle("Add Plan")
                    .scrollDisabled(false)
                    .background(.white)
                    .scrollContentBackground(.hidden)
            }

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
