//
//  CareView.swift
//  OCKSample
//
//  Created by Corey Baker on 11/24/20.
//  Copyright © 2020 Network Reconnaissance Lab. All rights reserved.
//
// swiftlint:disable:next line_length
// This file embeds a UIKit View Controller inside of a SwiftUI view. I used this tutorial to figure this out https://developer.apple.com/tutorials/swiftui/interfacing-with-uikit

import SwiftUI
import UIKit
import CareKit
import CareKitStore
import os.log

struct CareView: View {
    @State var storeManager = StoreManagerKey.defaultValue
    let colorStyler = ColorStyler()
    let appearanceStyler = AppearanceStyler()
    let dimensionStyler = DimensionStyler()

    @State private var showSheet = false

    @ObservedObject var careViewModel: CareViewModel

    @State private var score = 0

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    HStack {
                        Text("\(score)")
                            .font(.custom("Helvetica", fixedSize: 50))
                            .foregroundColor(ColorStyler.convertToColor(color: ColorStyler.iconBlue))
                            .fontWeight(.semibold)

                        #if os(iOS)
                            .padding(EdgeInsets(top: dimensionStyler.sidePadding,
                                leading: dimensionStyler.sidePadding + 17,
                                bottom: dimensionStyler.sidePadding / 3,
                                trailing: 0))
                        #endif
                        Text("trackScore")
                            .font(.title3)
                            .foregroundColor(ColorStyler.convertToColor(color: ColorStyler.iconRed))
                            .fontWeight(.light)
                            .frame(width: 100, height: 50, alignment: .bottom)
                    }.frame(width: dimensionStyler.screenWidth)
                        .background(ColorStyler.convertToColor(color: ColorStyler.iconYellow))
                    CareViewControllerRepresentable(careViewModel: careViewModel)
                }.frame(width: dimensionStyler.screenWidth)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showSheet.toggle()
                        }, label: {
                                Text("+")
                                    .font(.system(.largeTitle))
                                    .frame(width: 77, height: 70)
                                    .foregroundColor(ColorStyler.convertToColor(color: ColorStyler.iconYellow))
                                    .padding(.bottom, 7)
                            })
                            .background(ColorStyler.convertToColor(color: ColorStyler.iconBlue))
                            .cornerRadius(38.5)

                            .padding()
                            .shadow(color: Color.black.opacity(0.3),
                            radius: 3,
                            x: 3,
                            y: 3) }
                }
            }.sheet(isPresented: $showSheet) {
                NewPlanView(viewModel: .init())
                    .presentationDetents([.fraction(0.5)])
                    .presentationDragIndicator(.hidden)
                    .cornerRadius(15)
            }.onReceive(careViewModel.$trackScore) { value in
                score = value
            }
        }

    }
}

struct CareViewControllerRepresentable: UIViewControllerRepresentable {
    @State var storeManager = StoreManagerKey.defaultValue
    @ObservedObject var careViewModel: CareViewModel

    init(careViewModel: CareViewModel) {
        self.careViewModel = careViewModel
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = CareViewController(storeManager: storeManager, careViewModel: self.careViewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.backgroundColor = UIColor { $0.userInterfaceStyle == .light ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1): #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) }
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
}

struct CareView_Previews: PreviewProvider {
    static var previews: some View {
        CareView(storeManager: Utility.createPreviewStoreManager(), careViewModel: .init())
            .accentColor(Color(TintColorKey.defaultValue))
    }
}
