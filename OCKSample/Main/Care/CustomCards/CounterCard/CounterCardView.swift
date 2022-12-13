//
//  CustomCardView.swift
//  OCKSample
//
//  Created by Corey Baker on 12/3/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//
import SwiftUI
import CareKitUI
import CareKitStore

struct CounterCardView: View {
    @Environment(\.careKitStyle) var style
    @StateObject var viewModel: CounterCardViewModel

    var body: some View {
        CardView {
            VStack(alignment: .leading,
                   spacing: style.dimension.directionalInsets1.top) {

                HeaderView(title: Text(viewModel.taskEvents.firstEventTitle),
                           detail: Text(viewModel.taskEvents.firstTaskInstructions ?? ""))
                Divider()
                HStack(alignment: .center,
                       spacing: style.dimension.directionalInsets2.trailing) {

                    Button(action: {
                        Task {
                            viewModel.decrement()
                            await viewModel.action(viewModel.value)
                        }
                    }) {
                        CircularCompletionView(isComplete: viewModel.taskEvents.isFirstEventComplete) {
                            Image(systemName: "minus.circle.fill")
                                .resizable()
                                .padding()
                                .frame(width: 50, height: 50)
                        }
                    }
                    Spacer()

                    Text(viewModel.valueForButton)
                        .multilineTextAlignment(.trailing)
                        .font(Font.title.weight(.bold))
                        .foregroundColor(.accentColor)

                    Spacer()

                    Button(action: {
                        Task {
                            viewModel.increment()
                            await viewModel.action(viewModel.value)
                        }
                    }) {
                        CircularCompletionView(isComplete: viewModel.taskEvents.isFirstEventComplete) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .padding()
                                .frame(width: 50, height: 50)
                        }
                    }

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

struct CustomCardView_Previews: PreviewProvider {
    static var previews: some View {
        CounterCardView(viewModel: .init(storeManager: .init(wrapping: OCKStore(name: Constants.noCareStoreName,
                                                                                type: .inMemory))))
    }
}
