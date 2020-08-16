//
//  AdvancedTextField.swift
//  Cloud 53
//
//  Created by Андрей on 02.07.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import SwiftUI

class InputText: ObservableObject {
    
    @Published var text: String
    
    init(_ text: String) {
        self.text = text
    }
}

struct CustomTextField: UIViewRepresentable {
    
    class Coordinator: NSObject, UITextFieldDelegate {

        @Binding var change: Bool
        unowned private var text: InputText
        private var keyboard: UIKeyboardType
        private var maxLength: Int?

        init(text: InputText, keyboard: UIKeyboardType, maxLength: Int?, change: Binding<Bool>) {
            if keyboard == .phonePad {
                DispatchQueue.main.async {
                    if text.text.count == 0 {
                        text.text = "+"
                    }
                }
            }
            self._change = change
            self.text = text
            self.keyboard = keyboard
            self.maxLength = maxLength
        }
        
        func phoneCheck(_ textField: UITextField) {
            if self.keyboard == .phonePad {
                if textField.text == nil || textField.text!.count == 0 {
                    textField.text = "+"
                }
            }
        }
        
        func lengthCheck(_ textField: UITextField) {
            if let len = self.maxLength {
                if textField.text != nil && textField.text!.count > len {
                    let i = textField.text!.index(textField.text!.startIndex, offsetBy: len - 1)
                    textField.text = String(textField.text![...i])
                }
            }
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.phoneCheck(textField)
                self.lengthCheck(textField)
                self.text.text = textField.text ?? ""
                self.change.toggle()
            }
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return false
        }
    }
    
    func makeCoordinator() -> CustomTextField.Coordinator {
        return Coordinator(text: text, keyboard: self.keyboard, maxLength: self.maxLength, change: self.$change)
    }
    
    unowned var text: InputText
    @Binding var isResponder: Bool?
    @State private var change = false

    var isSecured: Bool = false
    var keyboard: UIKeyboardType = .default
    var maxLength: Int?

    func makeUIView(context: UIViewRepresentableContext<CustomTextField>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = isSecured
        textField.keyboardType = keyboard
        textField.delegate = context.coordinator
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomTextField>) {
        uiView.text = text.text
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentCompressionResistancePriority(.required, for: .vertical)
        if isResponder ?? false {
            uiView.becomeFirstResponder()
            DispatchQueue.main.async {
                self.isResponder = false
            }
        }
    }
}
