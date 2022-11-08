//
//  ViewType.swift
//  OCKSample
//
//  Created by seun on 11/8/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

struct SelectViewType: View {
    @Binding var viewType: ViewType
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        NavigationView {
            List {
                ForEach(ViewType.allCases) { value in
                    VStack {
                        Text(value.id)
                    }.onTapGesture {
                        viewType = value
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }.navigationTitle(Text("Select View Type"))
            .scrollDisabled(false)
            .background(.white)
            .scrollContentBackground(.hidden)
            .padding(EdgeInsets(top: 0,
            leading: 0,
            bottom: 0,
            trailing: 0))
            .navigationBarTitleDisplayMode(.automatic)
    }
}
