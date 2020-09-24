//
//  PhoneAuthView.swift
//  Cloud 53
//
//  Created by Андрей on 30.06.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import SwiftUI

private struct PhoneAuthSubview: SlidingView {
    
    var data: (title: String, input: Binding<String>, isPhone: Bool)
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            FigmaTitle(text: data.title)
                .padding(.top, Figma.y(86))
            Group {
                if data.isPhone {
                    FigmaTextField.phone(input: data.input)
                } else {
                    FigmaTextField.code(input: data.input)
                }
            }.padding(.top, Figma.y(208))
        }.padding(.horizontal, Figma.x(40))
    }
}

struct PhoneAuthView: View {
    
    @ObservedObject var keyboardResponder = KeyboardResponder()
    @Binding var isActive: Bool
    @EnvironmentObject var mc: ModelController
    @ObservedObject private var slideController = SlideController<PhoneAuthSubview>()
    @State private var data = [(title: "Укажите свой номер телефона", input: "", isPhone: true), (title: "Введите код из смс", input: "", isPhone: false)]
    
    @State private var isLoading: Bool = false
    @State private var message: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            SlideView(slideController: self.slideController, whenReturned: {self.isActive = false}, whenFinished: {})
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
            self.setContent()
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
    
    private func setContent() {
        var array: [(title: String, input: Binding<String>, isPhone: Bool)] = []
        for i in 0..<self.data.count {
            array.append((title: self.data[i].title, input: self.$data[i].input, isPhone: self.data[i].isPhone))
        }
        self.slideController.content = array
    }
    private func action() {
        isLoading = true
        changeMessage(nil)
        if slideController.step == 0 {
            mc.enterPhone(phone: data[0].input) { result in
                self.isLoading = false
                switch result {
                case .success:
                    self.slideController.next()
                case .failure(let error):
                    self.changeMessage(error.myDescription)
                }
            }
        } else if slideController.step == 1 {
            mc.enterCode(code: data[1].input) { result in
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
