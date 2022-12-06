//
//  MyNewCardView.swift
//  OCKSample
//
//  Created by seun on 12/1/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import CareKitUI
import CareKit
import CareKitStore
import SwiftUI

struct MyNewCardView: View {

    @Environment(\.careKitStyle) var style
    var standardInfo = ""
    var task: OCKAnyTask?
    var eventQuery: OCKEventQuery?
    var storeeManger: OCKSynchronizedStoreManager?

    var body: some View {
        CardView {
            HStack {
                Text("Now")
                Spacer()
                CardView {
                    Text("Hello World")
                }
            }

        }
        .careKitStyle(style)
    }
}

struct MyNewCardView_Previews: PreviewProvider {
    static var previews: some View {
        MyNewCardView()
    }
}
