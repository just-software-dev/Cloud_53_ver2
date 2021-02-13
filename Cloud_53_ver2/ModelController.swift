//
//  ModelController.swift
//  Cloud 53
//
//  Created by Андрей on 06.07.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

// Секции в приложении. Приветствие, вход и меню
enum AppSection {
    case intro
    case auth
    case menu
}

// update - обновление, link - привязка (помимо телефона привязать Apple ID), normal - вход
enum AuthCases {
    
    case update
    case link
    case normal
    
    func toString() -> String {
        switch self {
        case .update:
            return "update"
        case .link:
            return "link"
        case .normal:
            return "normal"
        }
    }

    static func fromString(s: String?) -> AuthCases? {
        switch s {
        case "update":
            return .update
        case "link":
            return .link
        case "normal":
            return .normal
        default:
            return nil
        }
    }
}

private enum AuthType {
    case apple
    case phone
}

struct UserInformation {
    var name: String
    var car: String
    var carBrand: String
    var discount: Int?
}

struct ParkingData: Encodable {
    var car_brand: String
    var car: String
    var phone: String
}

class ModelController: ObservableObject {
    
    @Published private(set) var currentSection: AppSection = .intro
    @Published private(set) var user: UserInformation? = nil
    
    private var lastAuth: AuthType? // Каким способом был выполнен вход
    private var handle: AuthStateDidChangeListenerHandle?
    private let appleLogin = AppleLogin()
    private let phoneLogin = PhoneLogin()
    let coreDataHelper = CoreDataHelper()
    private var isDefaultDiscount: Bool = false
    
    private func setSection(section: AppSection, isAnimation: Bool = false) {
        withAnimation(isAnimation ? .default : .none) {
            self.currentSection = section
        }
    }
    
    init() {
        start()
        if !UserDefaults.standard.bool(forKey: "endIntro") && Auth.auth().currentUser != nil {
            UserDefaults.standard.set(true, forKey: "endIntro")
        }
        updateSection()
        // Мониторинг того, выполнен вход или нет
        handle = Auth.auth().addStateDidChangeListener { [unowned model = self] (auth, user) in
            if model.user != nil && user == nil {
                DataMonitoring.shareInstance.removeObservers()
                model.resetData()
            }
            model.start()
            model.updateSection()
        }
        Auth.auth().languageCode = "ru"
    }
    
    private func updateSection() {
        if Auth.auth().currentUser == nil {
            if !UserDefaults.standard.bool(forKey: "endIntro") {
                if currentSection != .intro {
                    setSection(section: .intro, isAnimation: false)
                }
            } else if currentSection != .auth {
                setSection(section: .auth, isAnimation: true)
            }
        } else if currentSection != .menu {
            setSection(section: .menu, isAnimation: self.lastAuth == .apple)
        }
    }
    
    deinit {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    // Когда приветствие завершилось
    func endIntro() {
        UserDefaults.standard.set(true, forKey: "endIntro")
        updateSection()
    }
    
    // Выполнять, когда обновлена информация в Auth.auth().currentUser, чтобы сразу же обновить информацию на других устройствах
    func increaseUserVersion() {
        let newVersion: Int = UserDefaults.standard.integer(forKey: "account_version") + 1
        DataMonitoring.shareInstance.set(path: "users/\(Auth.auth().currentUser!.uid)/open/account_version", value: newVersion)
    }
    
    func enterPhone(phone: String, completion: @escaping(Result<String, Error>) -> Void) {
        phoneLogin.enterPhone(phone: phone, completion: completion)
    }
    
    func enterCode(code: String, mode: AuthCases = .normal, completion: @escaping(Result<AuthDataResult?, Error>) -> Void) {
        self.lastAuth = .phone
        phoneLogin.enterCode(code: code, mode: mode, completion: completion)
    }
    
    func appleAuth(mode: AuthCases = .normal, completion: ((Result<String?, Error>) -> Void)? = nil) {
        self.lastAuth = .apple
        appleLogin.handleAuthorizationAppleIDButtonPress(mode: mode, completion: completion)
    }
    
    func setName(_ name: String, completion: ((Error?, DatabaseReference) -> Void)? = nil) {
        guard let user = Auth.auth().currentUser else {return}
        UserDefaults.standard.set(name, forKey: "name")
        DataMonitoring.shareInstance.set(path: "users/\(user.uid)/open/name", value: name, completion: completion)
    }
    
    func setNameIfNotExists(_ name: String) {
        guard let user = Auth.auth().currentUser else {return}
        DataMonitoring.shareInstance.get(path: "users/\(user.uid)/open/name") { (snapshot) in
            DispatchQueue.main.async {
                if (snapshot.value as? String ?? "").isEmpty {
                    self.setName(name)
                }
            }
        }
    }
    
    func setCarNumber(_ car: String, completion: ((Error?, DatabaseReference) -> Void)? = nil) {
        guard let user = Auth.auth().currentUser else {return}
        UserDefaults.standard.set(car, forKey: "car")
        DataMonitoring.shareInstance.set(path: "users/\(user.uid)/open/car", value: car, completion: completion)
    }
    
    func setCarBrand(_ carBrand: String, completion: ((Error?, DatabaseReference) -> Void)? = nil) {
        guard let user = Auth.auth().currentUser else {return}
        UserDefaults.standard.set(carBrand, forKey: "car_brand")
        DataMonitoring.shareInstance.set(path: "users/\(user.uid)/open/car_brand", value: carBrand, completion: completion)
    }
    
    func parkingRequest(data: ParkingData, completion: @escaping (String) -> Void) {
        DataMonitoring.shareInstance.get(path: "information/parking/link") { (snapshot) in
            DispatchQueue.main.async {
                guard let link = snapshot.value as? String
                else {
                    completion("Данная функция временно недоступна")
                    return
                }
                guard let currentUser = Auth.auth().currentUser else {
                    completion("Ошибка. Вы не авторизованы")
                    return
                }
                currentUser.getIDTokenForcingRefresh(true) { token, error in
                    if let error = error {
                        completion(error.myDescription)
                        return
                    }
                    guard let token = token else {
                        completion("Ошибка. Не удалось получить токен")
                        return
                    }
                    MyHTTP.POST(url: link, data: data, token: token) { result in
                        switch result {
                        case .success(let data):
                            completion(String(decoding: data, as: UTF8.self))
                        case .failure(let error):
                            completion(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    private func resetData() {
        user = nil
        coreDataHelper.deleteData(entity: "Menu")
        coreDataHelper.deleteData(entity: "Promo")
        UserDefaults.standard.set(nil, forKey: "name")
        UserDefaults.standard.set(nil, forKey: "car")
        UserDefaults.standard.set(nil, forKey: "car_brand")
        UserDefaults.standard.set(nil, forKey: "account_version")
    }
    
    func logOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            DataMonitoring.shareInstance.removeObservers()
            self.resetData()
            self.setSection(section: .auth, isAnimation: true)
        }
    }
}

extension ModelController {
    
    // Проверяет, выполнен ли вход. Если да, то устанавливает наблюдателей, которые отвечают за получение информации с сервера
    private func start() {
        if user != nil || Auth.auth().currentUser == nil {return}
        user = UserInformation(
            name: UserDefaults.standard.string(forKey: "name") ?? "",
            car: UserDefaults.standard.string(forKey: "car") ?? "",
            carBrand: UserDefaults.standard.string(forKey: "car_brand") ?? "",
            discount: nil
        )
        // Мониторинг информации о пользователе
        DataMonitoring.shareInstance.observe(path: "users/\(Auth.auth().currentUser!.uid)/open") { (snapshot) in
            DispatchQueue.main.async {
                if !snapshot.exists() {
                    print("No data")
                    Auth.auth().currentUser!.reload() { (error) in
                        DispatchQueue.main.async {
                            if Auth.auth().currentUser != nil {
                                self.increaseUserVersion()
                            }
                        }
                    }
                    return
                }
                guard let dict = snapshot.value as? [String: Any] else {
                    print("Isn't dict")
                    return
                }
                if let name = dict["name"] as? String {
                    if name != self.user!.name {
                        UserDefaults.standard.set(name, forKey: "name")
                        self.user!.name = name
                    }
                }
                if let car = dict["car"] as? String {
                    if car != self.user!.car {
                        UserDefaults.standard.set(car, forKey: "car")
                        self.user!.car = car
                    }
                }
                if let carBrand = dict["car_brand"] as? String {
                    if carBrand != self.user!.carBrand {
                        UserDefaults.standard.set(carBrand, forKey: "car_brand")
                        self.user!.carBrand = carBrand
                    }
                }
                if let ver = dict["account_version"] as? Int {
                    if ver != UserDefaults.standard.integer(forKey: "account_version") {
                        Auth.auth().currentUser!.reload()
                        UserDefaults.standard.set(ver, forKey: "account_version")
                    }
                } else {
                    self.increaseUserVersion()
                }
            }
        }
        // Мониторинг разной текстовой информации
        DataMonitoring.shareInstance.observe(path: "information/realtime_configs") { (snapshot) in
            DispatchQueue.main.async {
                guard let dict = snapshot.value as? [String: Any] else {
                    print("Isn't dict")
                    return
                }
                if let loyalty = dict["loyalty"] as? String {
                    UserDefaults.standard.set(loyalty, forKey: "loyalty")
                }
                if let inst = dict["instagram"] as? String {
                    UserDefaults.standard.set(inst, forKey: "instagram")
                }
                if let geo = dict["apple_geo"] as? String {
                    UserDefaults.standard.set(geo, forKey: "apple_geo")
                }
                if let phone = dict["phone"] as? String {
                    UserDefaults.standard.set(phone, forKey: "phone")
                }
            }
        }
        // Мониторинг ссылок на аккаунты разработчиков
        DataMonitoring.shareInstance.observe(path: "information/devs") { (snapshot) in
            DispatchQueue.main.async {
                guard let dict = snapshot.value as? [String: Any] else {
                    print("Isn't dict")
                    return
                }
                if let maks = dict["maks"] as? String {
                    UserDefaults.standard.set(maks, forKey: "maks")
                }
                if let andrey = dict["andrey"] as? String {
                    UserDefaults.standard.set(andrey, forKey: "andrey")
                }
            }
        }
        // Мониторинг скидки
        DataMonitoring.shareInstance.observe(path: "users/\(Auth.auth().currentUser!.uid)/discount") { (snapshot) in
            DispatchQueue.main.async {
                if !snapshot.exists() {
                    self.getDefaultDiscount()
                    return
                }
                guard let discount = snapshot.value as? Int else {
                    self.getDefaultDiscount()
                    return
                }
                if self.isDefaultDiscount {
                    self.isDefaultDiscount = false
                    DataMonitoring.shareInstance.removeObservers(path: "information/default_discount")
                }
                self.user!.discount = discount
            }
        }
        let _: Menu? = self.download() // Мониторинг меню
        let _: Promo? = self.download() // Мониторинг акций
    }
    
//    Мониторинг меню/акций
    private func download<SomeEntity: MyEntity>(completion: (() -> Void)? = nil) -> SomeEntity? {
        var path = ""
        if SomeEntity.self == Promo.self {
            path = "information/promo"
        } else if SomeEntity.self == Menu.self {
            path = "information/menu"
        }
        DataMonitoring.shareInstance.observe(path: path) { (snapshot) in
            DispatchQueue.main.async {
                if let menu = snapshot.value as? [String: [String: Any]] {
                    let elements = SomeEntity.dictToItems(menu: menu)
                    withAnimation {
                        self.coreDataHelper.update(elements)
                    }
                }
                completion?()
            }
        }
        return nil
    }
    
    // Устанавливает пользователю скидку по умолчанию
    private func getDefaultDiscount() {
        isDefaultDiscount = true
        DataMonitoring.shareInstance.observe(path: "information/default_discount") { (snapshot) in
            DispatchQueue.main.async {
                if !snapshot.exists() {
                    print("Doesn't exist")
                    return
                }
                guard let discount = snapshot.value as? Int else {
                    print("Incorrect value")
                    return
                }
                self.user?.discount = discount
            }
        }
    }
}
