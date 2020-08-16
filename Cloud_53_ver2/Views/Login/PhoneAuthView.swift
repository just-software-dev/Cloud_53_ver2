//
//  PhoneAuthView.swift
//  Cloud 53
//
//  Created by Андрей on 30.06.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import SwiftUI

private struct PhoneAuthSubview: View {
    
    var title: String
    var isPhone: Bool
    unowned var it: InputText
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            FigmaTitle(text: title)
                .padding(.top, Figma.y(86))
            Group {
                if isPhone {
                    FigmaTextField.phone(input: it)
                } else {
                    FigmaTextField.code(input: it)
                }
            }.padding(.top, Figma.y(208))
        }.padding(.horizontal, Figma.x(40))
    }
}

struct PhoneAuthView: View {
    
    @ObservedObject var keyboardResponder = KeyboardResponder()
    @Binding var isActive: Bool
    @EnvironmentObject var mc: ModelController
    @ObservedObject private var slideController = SlideController()
    private let titles = ["Укажите свой номер телефона", "Введите код из смс"]
    private let types = [true, false]
    @ObservedObject private var phone = InputText("")
    @ObservedObject private var code = InputText("")
    
    @State private var isLoading: Bool = false
    @State private var message: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            SlideView(slideController: slideController, setView: { [view = self, unowned phone = self.phone, unowned code = self.code] step in
                return AnyView(PhoneAuthSubview(title: view.titles[step], isPhone: view.types[step], it: step == 0 ? phone : code))
            })
            VStack(spacing: 0) {
                Message(text: message, defaultHeight: 51)
                Button(action: { [view = self] in
                    UIApplication.shared.closeKeyboard()
                    view.next()
                }) {
                    FigmaButtonView(text: "Далее", loading: self.isLoading, type: .primary)
                }
                Button(action: {
                    UIApplication.shared.closeKeyboard()
                    self.back()
                }) {
                    FigmaButtonView(text: "Назад", loading: false, type: .secondary)
                }.padding(.top, 17)
                KeyboardBorder(keyboardResponder: keyboardResponder)
                    .padding(.top, 10)
                Spacer()
            }.padding(.horizontal, Figma.x(40))
        }.contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.closeKeyboard()
        }
//        .modifier(LiftContent(up: keyboardResponder.up))
    }
    
    private func changeMessage(_ text: String?) {
        withAnimation {
            message = text
        }
    }
    
    private func back() {
        self.changeMessage(nil)
        if slideController.step == 0 {
            isActive = false
        } else {
            self.slideController.back()
        }
    }
    
    private func next() {
//        isLoading = true
//        changeMessage(nil)
//        if slideController.step == 0 {
//            mc.enterPhone(phone: phone.text) { result in
//                self.isLoading = false
//                switch result {
//                case .success:
//                    self.slideController.next()
//                case .failure(let error):
//                    self.changeMessage(error.myDescription)
//                }
//            }
//        } else if slideController.step == 1 {
//            mc.enterCode(code: code.text) { result in
//                self.isLoading = false
//                switch result {
//                case .success:
//                    print("Success (phone auth)")
//                case .failure(let error):
//                    self.changeMessage(error.myDescription)
//                }
//            }
//        }
    }
}

//struct PhoneAuthView_Previews: PreviewProvider {
//    static var previews: some View {
//        PhoneAuthView()
//    }
//}
