//
//  LoginPage.swift
//  Cloud 53
//
//  Created by Андрей on 30.06.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import SwiftUI

struct LoginPage: View {
    
    @State private var isPhoneAuth: Bool = false
    @EnvironmentObject var mc: ModelController
    @State private var message: String?
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Image("logo")
            Spacer()
            NavigationLink(destination: PhoneAuthView(isActive: self.$isPhoneAuth).hideNavigationBar(), isActive: self.$isPhoneAuth) {
                FigmaButtonView(text: "Войти по номеру телефона", loading: false, type: .primary)
            }.padding(.bottom, 20)
            AppleButton(action: {self.changeMessage(nil)}) { result in
                switch result {
                case .success(let result):
                    guard let name = result else {return}
                    self.mc.setNameIfNotExists(name)
                case .failure(let error):
                    print("Apple login error: \(error.localizedDescription)")
                    self.changeMessage(error.myDescription)
                }
            }
            Message(text: self.message, defaultHeight: 20)
                .padding(.bottom)
        }.padding(.horizontal, Figma.x(20))
    }
    
    private func changeMessage(_ text: String?) {
        withAnimation {
            message = text
        }
    }
}

//struct LoginPage_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginPage()
//    }
//}
