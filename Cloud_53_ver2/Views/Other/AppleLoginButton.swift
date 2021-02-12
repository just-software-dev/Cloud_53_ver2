//
//  AppleLoginButton.swift
//  Cloud_53_ver2
//
//  Created by Андрей on 13.02.2021.
//  Copyright © 2021 oak. All rights reserved.
//

import AuthenticationServices
import SwiftUI

struct AppleButton: View {
    
    @EnvironmentObject var mc: ModelController
    
    var mode: AuthCases = .normal
    var action: (() -> Void)? = nil
    var completion: ((Result<String?, Error>) -> Void)? = nil
    
    private var type: ASAuthorizationAppleIDButton.ButtonType {
        get {
            switch self.mode {
            case .normal:
                return .signIn
            default:
                return .continue
            }
        }
    }
    
    var body: some View {
        UIAppleButton(type: type).onTapGesture {
            UIApplication.shared.closeKeyboard()
            self.action?()
            self.mc.appleAuth(mode: self.mode, completion: self.completion)
        }.frame(height: 47)
        .cornerRadius(30)
    }
}

private struct UIAppleButton: UIViewRepresentable {
    
    var type: ASAuthorizationAppleIDButton.ButtonType
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        return ASAuthorizationAppleIDButton(type: type, style: .white)
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
    }
}
