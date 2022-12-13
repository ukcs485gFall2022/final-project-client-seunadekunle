//
//  LoggerCardView.swift
//  OCKSample
//
//  Created by seun on 12/10/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI
import CareKitUI
import CareKitStore

struct LoggerCardView: View {
    @Environment(\.careKitStyle) var style
    @StateObject var viewModel: LoggerCardViewModel
    let colorStyler = ColorStyler()
    let appearanceStyler = AppearanceStyler()
    let dimensionStyler = DimensionStyler()

    var body: some View {
        CardView {
            VStack(alignment: .leading,
                   spacing: style.dimension.directionalInsets1.top) {

                HeaderView(title: Text(viewModel.taskEvents.firstEventTitle),
                           detail: Text(viewModel.taskEvents.firstTaskInstructions ?? ""))
                Divider()
                VStack(alignment: .center,
                       spacing: style.dimension.directionalInsets2.trailing) {

                    Text(viewModel.valueForButton)
                        .multilineTextAlignment(.trailing)
                        .font(Font.title.weight(.bold))
                        .foregroundColor(.accentColor)

                    HStack {
                        TextField("Log", text: $viewModel.value)
                            .padding()
                            .background(ColorStyler.convertToColor(color: colorStyler.customBackground))
                            .cornerRadius(appearanceStyler.cornerRadius1)
                            .listRowSeparator(.hidden)
                        Button(action: {
                            Task {
                                await viewModel.action(viewModel.value)
                            }
                        }) {
                            CircularCompletionView(isComplete: viewModel.taskEvents.isFirstEventComplete) {
                                Image(systemName: "circle.circle.fill")
                                    .resizable()
                                    .padding()
                                    .frame(width: 50, height: 50)
                            }
                        }
                    }.background(.white)
                        .scrollContentBackground(.hidden)
                        .padding(EdgeInsets(top: 0,
                                            leading: 0,
                                            bottom: 0,
                                            trailing: 0))

                    List(viewModel.outcomeValues) { value in
                        VStack {
                            HStack(alignment: .center) {
                                Text(value.description)
                                    .padding(.vertical, 2)
                                    .listRowSeparator(.hidden)
                                Text(viewModel.dateFormatter.string(from: value.createdDate))
                                    .font(.footnote)
                                    .padding(.vertical, 2)
                                    .listRowSeparator(.hidden)
                            }.padding(15)
                                .cornerRadius(appearanceStyler.cornerRadius1)
                                .background(ColorStyler.convertToColor(color: ColorStyler.iconBlue))
                                .foregroundColor(ColorStyler.convertToColor(color: ColorStyler.iconYellow))
                                .cornerRadius(appearanceStyler.cornerRadius1)
                                .frame(width: dimensionStyler.screenWidth / 0.9)
                        }
                        .listRowSeparator(.hidden)

                    }
                    .frame(height: dimensionStyler.screenHeight / 3)
                    .scrollContentBackground(.hidden)
                    .padding(EdgeInsets(top: 0,
                                        leading: 0,
                                        bottom: 0,
                                        trailing: 0))

                }

            }
                   .padding()
        }
        .onReceive(viewModel.$taskEvents) { taskEvents in
            /*
             DO NOT CHANGE THIS. The viewModel needs help
             from view to update "value" since taskEvents
             can't be overriden in viewModel.
             */
            viewModel.checkIfValueShouldUpdate(taskEvents)
        }

    }
}

struct LoggerCardView_Previews: PreviewProvider {
    static var previews: some View {
        LoggerCardView(viewModel: .init(storeManager: .init(wrapping: OCKStore(name: Constants.noCareStoreName,
                                                                               type: .inMemory))))
    }
}
