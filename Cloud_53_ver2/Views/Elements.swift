//
//  Elements.swift
//  Cloud 53
//
//  Created by Андрей on 30.06.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import SwiftUI

struct Blur: UIViewRepresentable {
    
    var style: UIBlurEffect.Style = .systemMaterial
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

enum ButtonType {
    case primary
    case secondary
}

struct FigmaButtonView: View {
    
    var text: String?
    var image: UIImage?
    var loading: Bool
    var type: ButtonType
    
    var body: some View {
        ZStack {
            self.chooseColor()
            if self.loading {
                Loading(color: .white)
                    .padding(7)
            } else {
                if image != nil {
                    Image(uiImage: image!)
                        .renderingMode(.original)
                        .resizable()
                        .padding(10)
                        .scaledToFit()
                } else if text != nil {
                    Text(text!)
                        .font(.SFUIDisplay(17.5))
                        .foregroundColor(.white)
                }
            }
            Spacer()
        }.frame(height: 47)
        .cornerRadius(30)
    }
    
    private func chooseColor() -> Color {
        switch self.type {
        case .primary:
            return Figma.red
        case .secondary:
            return Figma.gray
        }
    }
}

struct UnderlinedButtonView: View {
    
    var text: String
    
    var body: some View {
        Text(text)
            .underline()
            .foregroundColor(.white)
            .font(.SFUIDisplay(16))
    }
}

struct Message: View {
    
    var text: String?
    var defaultHeight: CGFloat = 0
    
    var body: some View {
        ZStack {
            Spacer().frame(height: defaultHeight)
            if text != nil {
                Text(text!)
                    .font(.SFUIDisplay(16))
                    .foregroundColor(Figma.lightGray)
                    .padding(.vertical, 10)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct FigmaTitle: View {
    
    var text: String

    var body: some View {
        Text(text)
            .font(.SFUIDisplay(26))
            .frame(width: Figma.x(250), alignment: Alignment.leading)
    }
}

struct FigmaTextField: View {
    
    var text: String
    @Binding var input: String
    var secure: Bool = false
    var keyboard: UIKeyboardType = .default
    var maxLength: Int
    var onChanged: (() -> Void)?
    
    @State private var isSelect: Bool? = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(self.text)
                .font(.SFProDisplay(14))
                .foregroundColor(Figma.lightGray)
            ScrollView(.horizontal, showsIndicators: false) {
                CustomTextField(text: self.$input, isResponder: self.$isSelect, isSecured: self.secure, keyboard: self.keyboard, maxLength: self.maxLength, onChanged: self.onChanged)
            }
            Divider()
                .background(Color.white)
        }
        .contentShape(Rectangle())
        .highPriorityGesture(TapGesture().onEnded {
            self.isSelect = true
        })
    }
    
    static func name(title: String = "Имя", input: Binding<String>, onChanged: (() -> Void)? = nil) -> FigmaTextField {
        FigmaTextField(text: title, input: input, secure: false, maxLength: 30, onChanged: onChanged)
    }
    
    static func phone(title: String = "Телефон", input: Binding<String>, onChanged: (() -> Void)? = nil) -> FigmaTextField {
        FigmaTextField(text: title, input: input, keyboard: .phonePad, maxLength: 16, onChanged: onChanged)
    }
    
    static func code(title: String = "Код", input: Binding<String>, onChanged: (() -> Void)? = nil) -> FigmaTextField {
        FigmaTextField(text: title, input: input, keyboard: .numberPad, maxLength: 6, onChanged: onChanged)
    }
}
