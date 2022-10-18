//
//  LoginView.swift
//  OCKSample
//
//  Created by Corey Baker on 10/29/20.
//  Copyright © 2020 Network Reconnaissance Lab. All rights reserved.
//

/*
 This is a variation of the tutorial found here:
 https://www.iosapptemplates.com/blog/swiftui/login-screen-swiftui
 */

import SwiftUI
import ParseSwift
import UIKit

/*
 Anything is @ is a wrapper that subscribes and refreshes
 the view when a change occurs. List to the last lecture
 in Section 2 for an explanation
 */
struct LoginView: View {
    @Environment(\.tintColor) var tintColor
    @Environment(\.tintColorFlip) var tintColorFlip
    @ObservedObject var viewModel: LoginViewModel
    @State var username = ""
    @State var password = ""
    @State var email = ""
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var signupLoginSegmentValue = 0
    let colorStyler = ColorStyler()
    let appearanceStyler = AppearanceStyler()
    let dimensionStyler = DimensionStyler()

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Image("track-icon")
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: dimensionStyler.splashIconSize,
                           height: dimensionStyler.splashIconSize,
                           alignment: .center)
                Text("Track")
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .frame(width: dimensionStyler.splashIconSize,
                           height: dimensionStyler.sidePadding,
                           alignment: .center)
                    .padding(EdgeInsets(top: dimensionStyler.sidePadding / 2,
                                        leading: 0,
                                        bottom: 0,
                                         trailing: 0))

            }.frame(width: dimensionStyler.screenWidth)
             .padding(EdgeInsets(top: dimensionStyler.sidePadding * 1.05,
                                 leading: 0,
                                 bottom: dimensionStyler.sidePadding * 1.5,
                                  trailing: 0))

            VStack(alignment: .leading) {
                TextField("Username", text: $username)
                    .padding()
                    .background(.white)
                    .cornerRadius(appearanceStyler.cornerRadius1)
                    .padding(EdgeInsets(top: -40,
                                   leading: dimensionStyler.sidePadding,
                                    bottom: 0,
                                    trailing: dimensionStyler.sidePadding))
                SecureField("Password", text: $password)
                    .padding()
                    .background(.white)
                    .cornerRadius(appearanceStyler.cornerRadius1)
                    .padding(EdgeInsets(top: dimensionStyler.sidePadding / 7.5,
                                   leading: dimensionStyler.sidePadding,
                                    bottom: 0,
                                    trailing: dimensionStyler.sidePadding))

                switch signupLoginSegmentValue {
                case 1:

                    TextField("First Name", text: $firstName)
                        .padding()
                        .background(.white)
                        .cornerRadius(appearanceStyler.cornerRadius1)
                        .padding(EdgeInsets(top: dimensionStyler.sidePadding / 7.5,
                                       leading: dimensionStyler.sidePadding,
                                        bottom: 0,
                                        trailing: dimensionStyler.sidePadding))
                    TextField("Last Name", text: $lastName)
                        .padding()
                        .background(.white)
                        .cornerRadius(appearanceStyler.cornerRadius1)
                        .padding(EdgeInsets(top: dimensionStyler.sidePadding / 7.5,
                                       leading: dimensionStyler.sidePadding,
                                        bottom: 0,
                                        trailing: dimensionStyler.sidePadding))
                    TextField("Email (optional)", text: $email)
                        .padding()
                        .background(.white)
                        .cornerRadius(appearanceStyler.cornerRadius1)
                        .padding(EdgeInsets(top: dimensionStyler.sidePadding / 7.5,
                                       leading: dimensionStyler.sidePadding,
                                        bottom: 0,
                                        trailing: dimensionStyler.sidePadding))

                default:
                    EmptyView()
                }
            }.padding()

            /*
             Notice that "action" and "label" are closures
             (which is essentially afunction as argument
             like we discussed in class)
             */
            Button(action: {
                switch signupLoginSegmentValue {
                case 1:
                    Task {
                        if email.isEmpty {
                            await viewModel.signup(.patient,
                                                   username: username,
                                                   password: password,
                                                   firstName: firstName,
                                                   lastName: lastName)
                        } else {
                            await viewModel.signup(.patient,
                                                   username: username,
                                                   password: password,
                                                   firstName: firstName,
                                                   lastName: lastName, email: email)
                        }
                    }
                default:
                    Task {
                        await viewModel.login(username: username,
                                              password: password)
                    }
                }
            }, label: {
                switch signupLoginSegmentValue {
                case 1:
                    Spacer()
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                    Spacer()

                default:
                    Spacer()
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                }
            })
            .background(convertToUIColor(color: colorStyler.iconBlue))
            .cornerRadius(appearanceStyler.cornerRadius1)
            .padding(EdgeInsets(top: 0,
                           leading: dimensionStyler.sidePadding + 17,
                            bottom: 0,
                            trailing: dimensionStyler.sidePadding + 17))

            Button(action: {
                Task {
                    await viewModel.loginAnonymously()
                }
            }, label: {
                switch signupLoginSegmentValue {
                case 0:
                    Text("Login Anonymously")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                default:
                    EmptyView()
                }
            })
            .background(convertToUIColor(color: colorStyler.iconYellow))
            .cornerRadius(appearanceStyler.cornerRadius1)
            .padding(EdgeInsets(top: dimensionStyler.sidePadding,
                           leading: dimensionStyler.sidePadding + 17,
                            bottom: 0,
                            trailing: dimensionStyler.sidePadding + 17))

            // If an error occurs show it on the screen, also make it multilline
            if let error = viewModel.loginError {
                Text("Error: \(error.message)")
                    .foregroundColor(convertToUIColor(color: colorStyler.quaternaryCustomFill))
                    .font(.system(size: 10))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(EdgeInsets(top: 0,
                                   leading: dimensionStyler.sidePadding,
                                    bottom: 0,
                                    trailing: dimensionStyler.sidePadding))
            }
            Spacer()

            /*
             Example of how to do the picker here:
             https://www.swiftkickmobile.com/creating-a-segmented-control-in-swiftui/
             */
            Picker(selection: $signupLoginSegmentValue,
                   label: Text("Login Picker")) {
                Text("Login").tag(0).background(convertToUIColor(color: colorStyler.customBackground))
                Text("Sign Up").tag(1).foregroundColor(convertToUIColor(color: colorStyler.iconYellow))
            }.pickerStyle(.segmented)
            .foregroundColor(convertToUIColor(color: colorStyler.iconYellow))
            .cornerRadius(appearanceStyler.cornerRadius1)
            .padding(EdgeInsets(top: 0,
                           leading: dimensionStyler.sidePadding,
                            bottom: dimensionStyler.sidePadding,
                            trailing: dimensionStyler.sidePadding))
        }.padding(EdgeInsets(top: 0,
                       leading: 0,
                        bottom: 0,
                        trailing: 0))
         .background(convertToUIColor(color: colorStyler.customBackground))
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: .init())
            .accentColor(Color(TintColorKey.defaultValue))
    }
}

func convertToUIColor(color: UIColor) -> Color {
    return Color.init(uiColor: color)
}
