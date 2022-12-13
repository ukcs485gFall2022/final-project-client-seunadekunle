//
//  NewGoalsTopView.swift
//  OCKSample
//
//  Created by seun on 12/9/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

struct NewGoalsTopView: View {
    @StateObject var viewModel: NewGoalsViewModel
    let colorStyler = ColorStyler()
    let appearanceStyler = AppearanceStyler()
    let dimensionStyler = DimensionStyler()

    var body: some View {
        Picker("Select the type", selection: $viewModel.taskType) {
            ForEach(viewModel.ockTaskTypes, id: \.self) {
                Text($0)
            }
        }
        .foregroundColor(ColorStyler.convertToColor(color: ColorStyler.iconYellow))
        .pickerStyle(.menu)

        TextField("Title", text: $viewModel.title)
            .padding()
            .background(ColorStyler.convertToColor(color: colorStyler.customBackground))
            .cornerRadius(appearanceStyler.cornerRadius1)
            .listRowSeparator(.hidden)

        TextField("Instructions", text: $viewModel.instructions)
            .padding()
            .background(ColorStyler.convertToColor(color: colorStyler.customBackground))
            .cornerRadius(appearanceStyler.cornerRadius1)
            .listRowSeparator(.hidden)

        Picker("Select the Plan", selection: $viewModel.plan) {
            ForEach(viewModel.plans, id: \.self) {
                Text($0.title).tag($0.uuid)
            }
        }.listRowSeparator(.hidden)
    }
}

struct NewGoalsTopView_Previews: PreviewProvider {
    static var previews: some View {
        NewGoalsTopView(viewModel: .init())
    }
}
