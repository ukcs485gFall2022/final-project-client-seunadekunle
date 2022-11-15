//
//  ProfileView.swift
//  OCKSample
//
//  Created by Corey Baker on 11/24/20.
//  Copyright © 2020 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI
import CareKitUI
import CareKitStore
import CareKit
import os.log

struct ProfileView: View {
    @Environment(\.tintColor) private var tintColor
    @StateObject var viewModel = ProfileViewModel()
    @ObservedObject var loginViewModel: LoginViewModel

    let colorStyler = ColorStyler()
    let appearanceStyler = AppearanceStyler()
    let dimensionStyler = DimensionStyler()

    var body: some View {

        NavigationView {
            VStack {
                ProfileImageView(viewModel: viewModel)

                if let username = viewModel.username {
                    Text(username)
                }

                Form {
                    ProfileInputView(viewModel: viewModel)

                    Button(action: {
                        Task {
                            await viewModel.saveProfile()
                            try await viewModel.saveContact()
                        }
                    }, label: {
                            Text("Save Profile")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()

                        })
                        .frame(width: dimensionStyler.screenWidth / 1.25)
                        .background(colorStyler.convertToColor(color: colorStyler.iconYellow))
                        .cornerRadius(appearanceStyler.cornerRadius1)
                        .listRowSeparator(.hidden)

                    // Notice that "action" is a closure (which is essentially
                    // a function as argument like we discussed in class)
                    Button(action: {
                        Task {
                            await loginViewModel.logout()
                        }
                    }, label: {
                            Text("Log Out")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: dimensionStyler.screenWidth)
                        })
                        .listRowSeparator(.hidden)
                        .frame(width: dimensionStyler.screenWidth / 1.25)
                        .background(colorStyler.convertToColor(color: colorStyler.iconRed))
                        .cornerRadius(appearanceStyler.cornerRadius1)
                }
                .background(.white)
                .scrollContentBackground(.hidden)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("MyContact") {
                        viewModel.isPresentingContact = true
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.isPresentingAddTask = true
                    }, label: {
                            Text("Add Task")
                        })
                        .sheet(isPresented: $viewModel.isPresentingAddTask) {
                            NewGoalsView(viewModel: .init())
                            .presentationDetents([.fraction(0.925)])
                            .presentationDragIndicator(.hidden)
                    }
                }
            }
            .sheet(isPresented: $viewModel.isPresentingContact) {
                MyContactView().presentationDetents([.fraction(0.925)])
                .cornerRadius(15)
            }
            .sheet(isPresented: $viewModel.isPresentingImagePicker) {
                ImagePicker(image: $viewModel.profileUIImage)
            }
            .alert(isPresented: $viewModel.isShowingSaveAlert) {
            return Alert(title: Text("Update"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("Ok"), action: {
                        viewModel.isShowingSaveAlert = false
                    }))
            }

        }

    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: .init(storeManager: Utility.createPreviewStoreManager()),
            loginViewModel: .init())
            .accentColor(Color(TintColorKey.defaultValue))
    }
}
