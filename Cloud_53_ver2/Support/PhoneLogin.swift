//
//  PhoneLogin.swift
//  Cloud 53
//
//  Created by Андрей on 05.08.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import FirebaseAuth

final class PhoneLogin {
    
    private var id: String?
    
    func enterPhone(phone: String, completion: @escaping(Result<String, Error>) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { (result, error) in
            if let error = error {
                completion(.failure(error))
            } else if let result = result {
                self.id = result
                completion(.success(result))
            }
        }
    }
    
    func enterCode(code: String, mode: AuthCases = .normal, completion: @escaping(Result<AuthDataResult?, Error>) -> Void) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.id!, verificationCode: code)
        switch mode {
        case .normal:
            Auth.auth().signIn(with: credential) { (result, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let result = result {
                    completion(.success(result))
                }
            }
        case .update:
            Auth.auth().currentUser?.updatePhoneNumber(credential) { (error) in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(nil))
                }
            }
        case .link:
            Auth.auth().currentUser?.link(with: credential) { (result, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let result = result {
                    completion(.success(result))
                }
            }
        }
    }
}
