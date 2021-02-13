//
//  PhoneAuthView.swift
//  Cloud 53
//
//  Created by Андрей on 30.06.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import SwiftUI

private struct PhoneAuthSubview: View {
    
    @Binding var input: String
    var data: (title: String, isPhone: Bool)
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            FigmaTitle(text: data.title)
                .padding(.top, Figma.y(86))
            Group {
                if data.isPhone {
                    FigmaTextField.phone(input: $input)
                } else {
                    FigmaTextField.code(input: $input)
                }
            }.padding(.top, Figma.y(208))
        }.padding(.horizontal, Figma.x(40))
    }
}

struct PhoneAuthView: View {
    
    @ObservedObject var keyboardResponder = KeyboardResponder()
    @Binding var isActive: Bool
    @EnvironmentObject var mc: ModelController
    @ObservedObject private var slideController = SlideController(2)

    private let data = [
        (title: "Укажите свой номер телефона", isPhone: true),
        (title: "Введите код из смс", isPhone: false)
    ]

    @State private var isLoading: Bool = false
    @State private var message: String? = nil

    @State private var phone: String = ""
    @State private var code: String = ""

    var body: some View {
        VStack(spacing: 0) {
            SlideView(slideController: self.slideController) { step in
                Group {
                    if step == 0 {
                        PhoneAuthSubview(input: self.$phone, data: self.data[step])
                    } else {
                        PhoneAuthSubview(input: self.$code, data: self.data[step])
                    }
                }
            }
            VStack(spacing: 0) {
                Message(text: message, defaultHeight: 51)
                FigmaButton(text: "Далее", loading: self.isLoading, type: .primary) {
                    self.action()
                }
                FigmaButton(text: "Назад", loading: false, type: .secondary) {
                    self.changeMessage(nil)
                    self.slideController.back()
                }.padding(.top, 17)
                KeyboardBorder(keyboardResponder: keyboardResponder)
                    .padding(.top, 10)
                Spacer()
            }.padding(.horizontal, Figma.x(40))
        }.onAppear() {
            self.slideController.onReturned = { self.isActive = false }
        }.contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.closeKeyboard()
        }
        .modifier(LiftContent(up: keyboardResponder.up))
    }
    
    private func changeMessage(_ text: String?) {
        withAnimation {
            message = text
        }
    }

    private func action() {
        isLoading = true
        changeMessage(nil)
        if slideController.step == 0 {
            mc.enterPhone(phone: self.phone) { result in
                self.isLoading = false
                switch result {
                case .success:
                    self.slideController.next()
                case .failure(let error):
                    self.changeMessage(error.myDescription)
                }
            }
        } else if slideController.step == 1 {
            mc.enterCode(code: self.code) { result in
                self.isLoading = false
                switch result {
                case .success:
                    self.slideController.next()
                case .failure(let error):
                    self.changeMessage(error.myDescription)
                }
            }
        }
    }
}
