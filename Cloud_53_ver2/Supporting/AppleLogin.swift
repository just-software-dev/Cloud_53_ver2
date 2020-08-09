//
//  AppleAuthorizationController.swift
//  Cloud 53
//
//  Created by Андрей on 03.08.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import AuthenticationServices
import FirebaseAuth
import CryptoKit
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

final class AppleLogin: NSObject, ASAuthorizationControllerDelegate {
    
    private var currentNonce: String?
    private var completion: ((Result<String?, Error>) -> Void)? = nil
    
    func handleAuthorizationAppleIDButtonPress(mode: AuthCases = .normal, completion: ((Result<String?, Error>) -> Void)? = nil) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
        request.state = mode.toString()
        self.completion = completion
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            // Create an account in your system.

            let fullName = appleIDCredential.fullName
            
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialise token string from data: \(appleIDToken.debugDescription)")
                return
            }
            guard let state = AuthCases.fromString(s: appleIDCredential.state) else {
                print("Invalid state: request must be started with one of the AuthCases")
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            
            switch state {
            case .normal:
                Auth.auth().signIn(with: credential) { (result, error) in
                    if let error = error {
                        if let completion = self.completion {
                            completion(.failure(error))
                        }
                    } else {
                        if (UserDefaults.standard.string(forKey: "name") ?? "").isEmpty && fullName != nil {
                            UserDefaults.standard.set(fullName!.givenName, forKey: "name")
                        }
                        if let completion = self.completion {
                            completion(.success(fullName?.givenName))
                        }
                    }
                    self.completion = nil
                }
            case .link:
                Auth.auth().currentUser?.link(with: credential) { (result, error) in
                    if let error = error {
                        if let completion = self.completion {
                            completion(.failure(error))
                        }
                    } else {
                        if let completion = self.completion {
                            completion(.success(fullName?.givenName))
                        }
                    }
                    self.completion = nil
                }
            case .update:
                print("Apple ID updating isn't available")
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple authorization error: \(error.localizedDescription)")
        if let completion = self.completion {
            completion(.failure(error))
        }
    }
}

extension AppleLogin: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!
    }
}

func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length

    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
              return random
        }

        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }

            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }

    return result
}

@available(iOS 13, *)
private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
    }.joined()

    return hashString
}
