//
//  KeyboardBorder.swift
//  Cloud 53
//
//  Created by Андрей on 29.06.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import SwiftUI

class KeyboardResponder: ObservableObject {
    
    private var notificationCenter: NotificationCenter
    private var isShow = false
    private var y_: CGFloat?
    @Published private(set) var up: CGFloat = 0
    @Published private(set) var keyboardHeight: CGFloat = 0
    
    private var up_: CGFloat {
        get {
            return self.up
        }
        set(value) {
            withAnimation(Animation.easeInOut(duration: 0.25)) {
                self.up = value >= 0 ? value : 0
            }
        }
    }
    
    var y: CGFloat? {
        get {
            return self.y_
        }
        set(value) {
            self.y_ = value != nil ? UIScreen.main.bounds.height - value! : value
        }
    }

    init() {
        notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let height = keyboardSize.height
            
            DispatchQueue.main.async {
                self.keyboardHeight = height
            }
            
            guard let y = self.y_ else {return}
            if height > y || isShow {
                self.up_ += height - y
            }
            self.isShow = true
        }
    }

    @objc private func keyboardWillHide(notification: Notification) {
        DispatchQueue.main.async {
            self.up_ = 0
            self.isShow = false
            self.keyboardHeight = 0
        }
    }
}

struct KeyboardBorder: View {
    
    @ObservedObject var keyboardResponder: KeyboardResponder
    @State private var isActive = false

    var body: some View {
        GeometryReader { geometry in
            Group { () -> AnyView in
                DispatchQueue.main.async {
                    if self.isActive {
                        self.keyboardResponder.y = geometry.frame(in: .global).maxY
                    }
                }
                return AnyView(Color.clear)
            }
        }.onAppear() {
            self.isActive = true
        }
        .onDisappear() {
            self.isActive = false
        }
        .frame(width: 0, height: 0)
    }
}

struct LiftContent: ViewModifier {
    
    var up: CGFloat
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .padding(.top, -self.up + UIApplication.shared.getSafeAreaSize(.top))
                .frame(height: geometry.size.height, alignment: .top)
                .clipped()
        }.edgesIgnoringSafeArea(.all)
    }
}
