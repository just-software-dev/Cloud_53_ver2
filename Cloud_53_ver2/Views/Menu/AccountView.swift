//
//  AccountView.swift
//  Cloud 53
//
//  Created by Андрей on 08.07.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import SwiftUI
import FirebaseAuth

private struct DevInform: Hashable {
    var id: String
    var name: String
    var button: String
}

private struct DevsView: View {
    
    @Binding var isDevs: Bool
    private var devs = [DevInform(id: "maks", name: "Макс", button: "Связаться с Максом"),
                        DevInform(id: "andrey", name: "Андрей", button: "Связаться с Андреем")]
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {self.isDevs.toggle()}) {
                        Image(systemName: "multiply")
                        .resizable()
                        .font(Font.title.weight(.light))
                        .frame(width: 20, height: 20)
                        .foregroundColor(Figma.lightGray)
                    }.padding(30)
                }
                Spacer()
            }
            VStack(spacing: 42) {
                HStack(spacing: Figma.x(56)) {
                    ForEach(devs, id: \.self) { dev in
                        VStack(spacing: 9) {
                            Image(dev.id)
                                .resizable()
                                .scaledToFit()
                                .clipShape(Circle())
                                .frame(height: Figma.x(92))
                            Text(dev.name)
                                .font(.SFUIDisplay(16))
                        }
                    }
                }
                VStack(spacing: 22) {
                    ForEach(devs, id: \.self) { dev in
                        FigmaButton(text: dev.button, loading: false, type: .secondary) {
                            guard let s = UserDefaults.standard.string(forKey: dev.id), let url = URL(string: s) else {
                                return
                            }
                            UIApplication.shared.open(url)
                        }.frame(width: Figma.x(290))
                    }
                }
            }
        }.background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
    
    fileprivate init(isDevs: Binding<Bool>) {
        self._isDevs = isDevs
    }
}

private enum AuthStatus {
    case phone
    case apple
    case both
}

private enum AlertCase {
    case exit
    case appleName
}

struct AccountView: View {
    
    @EnvironmentObject var mc: ModelController
    
    @State var isDevs = false
    
    @State private var name = ""
    @State private var phone = Auth.auth().currentUser?.phoneNumber ?? ""
    @State private var code = ""
    @State private var isCode = false
    @State private var showingAlert = false
    @State private var alertCase: AlertCase = .exit
    @State private var appleName = ""
    
    @State private var isLoading: Bool = false
    @State private var message: String? = nil
    @State private var previousPhone = ""
    @State private var authStatus: AuthStatus? = {
        guard let user = Auth.auth().currentUser else {return nil}
        var providers: [String] = []
        for e in user.providerData {
            providers.append(e.providerID)
        }
        let isApple = providers.contains("apple.com")
        let isPhone = providers.contains("phone")
        if isApple && isPhone {
            return .both
        } else if isPhone {
            return .phone
        } else {
            return .apple
        }
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            FigmaTextField.name(input: self.$name)
                .padding(.top, 13)
            FigmaTextField.phone(input: self.$phone) {
                if (self.phone != self.previousPhone) && self.isCode {
                    self.changeIsCode(false)
                    self.previousPhone = self.phone
                }
            }.padding(.top, 24)
            if isCode {
                FigmaTextField.code(title: "Код из смс", input: self.$code)
                    .padding(.top, 24)
            }
            Message(text: self.message, defaultHeight: 24)
            VStack(spacing: 17) {
                FigmaButton(text: "Изменить данные", loading: self.isLoading, type: .primary) {
                    self.changeData()
                }
                if authStatus == .phone {
                    AppleButton(mode: .link, action: {self.changeMessage(nil, add: false)}, completion: self.setApple)
                }
                FigmaButton(text: "Выйти", loading: false, type: .secondary) {
                    self.alertCase = .exit
                    self.showingAlert = true
                }
            }
            Button(action: {
                UIApplication.shared.closeKeyboard()
                self.isDevs.toggle()
            }) {
                HStack {
                    UnderlinedButtonView(text: "Гении разработки")
                    Text("👻").font(.SFUIDisplay(16))
                }
            }.padding(.top, 64)
        }.padding(.horizontal, 40)
        .alert(isPresented: $showingAlert) {
            self.chooseAlert()
        }
        .onAppear() {
            self.name = self.mc.user?.name ?? ""
        }
        .sheet(isPresented: self.$isDevs) {
            DevsView(isDevs: self.$isDevs)
        }
    }
    
    private func chooseAlert() -> Alert {
        switch alertCase {
        case .appleName:
            return Alert(title: Text("Хотите заменить ваше имя на «\(self.appleName)»?"), primaryButton: .default(Text("Нет")) {self.appleName = ""}, secondaryButton: .destructive(Text("Да")) {
                    self.mc.setName(self.appleName)
                    self.name = self.appleName
                })
        case .exit:
            return Alert(title: Text("Вы действительно хотите выйти из аккаунта?"), primaryButton: .default(Text("Да")) {self.mc.logOut()}, secondaryButton: .destructive(Text("Нет")))
        }
    }
    
    private func changeData() {
        self.isLoading = true
        self.changeMessage(nil, add: false)
        var phoneChange = false
        var nameChange = false
        if phone != Auth.auth().currentUser?.phoneNumber ?? "+" {
            phoneChange = true
            if !isCode {
                previousPhone = phone
                mc.enterPhone(phone: self.phone) { result in
                    self.isLoading = false
                    switch result {
                    case .success:
                        self.changeIsCode(true)
                    case .failure(let error):
                        self.changeMessage(error.myDescription)
                    }
                }
            } else {
                if authStatus == .both || authStatus == .phone {
                    mc.enterCode(code: self.code, mode: .update) { result in
                        self.isLoading = false
                        switch result {
                        case .success:
                            self.changeMessage("Новый номер телефона привязан успешно.")
                            self.mc.increaseUserVersion()
                            self.changeIsCode(false)
                        case .failure(let error):
                            self.changeMessage(error.myDescription)
                        }
                    }
                } else {
                    mc.enterCode(code: self.code, mode: .link) { result in
                        self.isLoading = false
                        switch result {
                        case .success:
                            self.changeMessage("Номер телефона привязан успешно.")
                            self.mc.increaseUserVersion()
                            self.changeIsCode(false)
                        case .failure(let error):
                            self.changeMessage(error.myDescription)
                        }
                    }
                }
            }
        }
        if name != mc.user?.name ?? "" {
            nameChange = true
            mc.setName(name) { (error, ref) in
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.changeMessage(error?.myDescription ?? "Имя успешно изменено.")
                }
            }
        }
        if !(phoneChange || nameChange) {
            self.isLoading = false
            self.changeMessage("Вы пока ничего не изменили.", add: false)
        }
    }
    
    private func setApple(_ result: Result<String?, Error>) {
        switch result {
        case .success(let result):
            self.changeMessage("Ваш аккаунт Apple успешно привязан")
            withAnimation {
                self.authStatus = .both
            }
            if let name = result {
                self.alertCase = .appleName
                self.appleName = name
                self.showingAlert = true
            }
        case .failure(let error):
            self.changeMessage(error.myDescription)
        }
    }
    
    private func changeIsCode(_ isCode: Bool) {
        withAnimation {
            self.isCode = isCode
        }
    }
    
    private func changeMessage(_ text: String?, add: Bool = true) {
        withAnimation {
            if message == nil || message!.isEmpty || !add {
                message = text
            } else {
                message! += " " + (text ?? "")
            }
        }
    }
}

//struct AccountView_Previews: PreviewProvider {
//    static var previews: some View {
//        AccountView()
//    }
//}
