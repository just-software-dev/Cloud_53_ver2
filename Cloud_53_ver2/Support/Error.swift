//
//  Error.swift
//  Cloud 53
//
//  Created by Андрей on 08.08.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import Foundation
import FirebaseAuth

extension Error {
    
    var myDescription: String {
        get {
            if let errCode = AuthErrorCode(rawValue: self._code) {
                switch errCode {
                case .invalidVerificationCode:
                    return "Неверный код."
                case .invalidPhoneNumber:
                    return "Номер телефона введён некорректно."
                case .networkError:
                    return "Нет соединения с интернетом."
                case .credentialAlreadyInUse:
                    return "Данный телефон/Apple ID уже привязан к другому аккаунту."
                case .webContextCancelled:
                    return "Если CAPTCHA не загружается, перезапустите приложение и попробуйте пройти её ещё раз."
                case .missingVerificationCode:
                    return "Введите код из смс."
                default:
                    return self.localizedDescription
                }
            } else {
                return self.localizedDescription
            }
        }
    }
}
