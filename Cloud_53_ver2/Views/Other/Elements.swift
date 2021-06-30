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

struct NativeLoading: UIViewRepresentable {

    private let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<NativeLoading>) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: style)
        view.startAnimating()
        return view
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<NativeLoading>) {}
    
    init(style: UIActivityIndicatorView.Style = .medium) {
        self.style = style
    }
}

enum ButtonType {
    case primary
    case secondary
}

// Внешний вид кнопки
struct FigmaButtonView: View {
    
    var text: String?
    var image: UIImage?
    var loading: Bool
    var type: ButtonType
    private var bgColor: Color
    private var contentColor: Color
    
    var body: some View {
        ZStack {
            self.bgColor
            if self.loading {
                NativeLoading()
            } else {
                if image != nil {
                    Image(uiImage: image!)
                        .renderingMode(.original)
                        .resizable()
                        .padding(10)
                        .scaledToFit()
                        .foregroundColor(contentColor)
                } else if text != nil {
                    Text(text!)
                        .font(.SFUIDisplay(17.5))
                        .foregroundColor(contentColor)
                }
            }
            Spacer()
        }.frame(height: 47)
        .cornerRadius(30)
    }
    
    init(text: String? = nil, image: UIImage? = nil, loading: Bool, type: ButtonType) {
        self.text = text
        self.image = image
        self.loading = loading
        self.type = type
        
        switch type {
        case .primary:
            self.bgColor = Figma.red
            self.contentColor = .white
        case .secondary:
            self.bgColor = Figma.gray
            self.contentColor = .white
        }
    }
}

struct FigmaButton: View {
    
    var action: () -> Void
    var text: String?
    var image: UIImage?
    var loading: Bool
    var type: ButtonType
    
    var body: some View {
        Button(action: {
            UIApplication.shared.closeKeyboard()
            if !self.loading {
                self.action()
            }
        }) {
            FigmaButtonView(text: text, image: image, loading: loading, type: type)
        }
    }
    
    init(text: String? = nil, image: UIImage? = nil, loading: Bool, type: ButtonType, action: @escaping () -> Void) {
        self.action = action
        self.text = text
        self.image = image
        self.loading = loading
        self.type = type
    }
}

// Внешний вид кнопки (текст с подчеркиванием)
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
