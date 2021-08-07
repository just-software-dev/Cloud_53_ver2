//
//  MenuView.swift
//  Cloud 53
//
//  Created by Андрей on 08.07.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import SwiftUI
import FirebaseAuth

// cold - для кнопок, warm - для скидки и карты
private enum TextureType {
    case cold
    case warm
}

// Обрезка текстур для получения View из них
private struct TextureBackground: View {
    
    var y: CGFloat
    var texture: TextureType = .cold
    var blackout: Alignment = .leading
    private let shadow = Color(UIColor(red: 0, green: 0, blue: 0, alpha: 0.5))
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Image(uiImage: self.getImage(rect: CGRect(x: 0, y: self.y, width: geometry.size.width, height: geometry.size.height)))
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                if self.blackout == .leading {
                    LinearGradient(gradient: Gradient(colors: [Color.blackout(0.7), .clear]), startPoint: .leading, endPoint: .trailing)
                } else if self.blackout == .center {
                    LinearGradient(gradient: Gradient(colors: [.clear, Color.blackout(0.5), Color.blackout(0.5), .clear]), startPoint: .leading, endPoint: .trailing)
                } else if self.blackout == .bottom {
                    LinearGradient(gradient: Gradient(colors: [Color.blackout(0.5), .clear]), startPoint: .bottom, endPoint: .top)
                }
            }
        }.clipShape(RoundedRectangle(cornerRadius: 30))
    }
    
    func getImage(rect: CGRect) -> UIImage {
        let image = UIImage(named: self.texture == .cold ? "cold_texture" : "warm_texture")!
        let cgImage = image.cgImage! // better to write "guard" in realm app
        let croppedCGImage = cgImage.cropping(to: rect)
        return UIImage(cgImage: croppedCGImage!)
    }
}

// Всплывающее окно с QR-кодом
private struct QRwindow: View {
    
    @EnvironmentObject var mc: ModelController
    @State var qrcode: UIImage?
    @State var message: String?
    
    var body: some View {
        ZStack {
            if qrcode != nil {
                Image(uiImage: qrcode!)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
            } else {
                if message == nil {
                    Loading(color: .black)
                        .frame(width: Figma.x(75), height: Figma.x(75))
                } else {
                    Text(message!)
                        .font(.body)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                }
            }
        }.padding(Figma.x(40))
        .background(Color.white)
        .onAppear() {
            // Получение ссылки для официантов
            DataMonitoring.shareInstance.get(path: "information/discount_link") { (snapshot) in
                DispatchQueue.main.async {
                    guard let link = snapshot.value as? String,
                        let uid = Auth.auth().currentUser?.uid
                    else {
                        self.changeMessage("Данная функция скоро появится")
                        return
                    }
                    // Установка времени открытия QR-кода (чтобы qr-код работал только определенное время после открытия)
                    DataMonitoring.shareInstance.set(path: "users/\(uid)/open/qr_time", value: self.currentDate()) { (error, ref) in
                        DispatchQueue.main.async {
                            if error != nil {
                                self.changeMessage("Данная функция скоро появится")
                            } else {
                                self.changeLink(link: link, uid: uid)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Преобразование ссылки в QR-код
    private func changeLink(link: String, uid: String) {
        DispatchQueue.global(qos: .userInteractive).async {
            let qr = QRcode.shared.generateQR("\(link)/\(uid)")
            withAnimation {
                self.qrcode = qr
            }
        }
    }
    
    private func changeMessage(_ text: String?) {
        withAnimation {
            message = text
        }
    }
    
    private func currentDate() -> String {
        let date = Date()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let year = calendar.component(.year, from: date)
        let mounth = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        return "\(year).\(mounth).\(day).\(hour).\(minute)"
    }
}

// Карта посетителя (не QR-код, а плашка с логотипом)
private struct LoyaltyCard: View {
    
    @State private var spacing: CGFloat = 0
    @Binding private var popupView: AnyView?
    
    private let modalPresentAction: ModalPresentAction
    
    var body: some View {
        ZStack {
            TextureBackground(y: 50, texture: .warm, blackout: .bottom)
            VStack(spacing: 0) {
                Spacer().frame(height: 45)
                ZStack {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                }.frame(height: 100)
                ZStack {
                    Button(action: {
                        withAnimation {
                            self.popupView = AnyView(QRwindow())
                        }
                    }) {
                        UnderlinedButtonView(text: "Показать карту")
                            .frame(height: 45)
                    }
                    HStack {
                        Spacer()
                        Button(action: {
                            self.modalPresentAction(
                                InstructionVC(),
                                UIScreen.main.bounds.height / 1.75,
                                true
                            )
                        }) {
                            Image(systemName: "questionmark.circle")
                                .resizable()
                                .font(Font.title.weight(.light))
                                .frame(width: 23, height: 23)
                                .foregroundColor(.white)
                                .padding(.trailing, 14)
                        }
                    }
                }
            }
        }
    }
    
    init(modalPresentAction: @escaping ModalPresentAction, popupView: Binding<AnyView?>) {
        self.modalPresentAction = modalPresentAction
        self._popupView = popupView
    }
}

private struct GrayButton: View {
    
    @State private var iconName: String = ""
    @Binding var isError: Bool
    private var i: Int
    
    var body: some View {
        FigmaButton(image: UIImage(named: iconName), loading: false, type: .secondary) {
            self.action()
        }.onAppear() {
            switch self.i {
            case 0:
                self.iconName = "location"
            case 1:
                self.iconName = "instagram"
            case 2:
                self.iconName = "phone"
            default:
                fatalError("Incorrect i")
            }
        }
    }
    
    init(i: Int, isError: Binding<Bool>) {
        self.i = i
        self._isError = isError
    }
    
    func action() {
        switch i {
        case 0:
            guard let s = UserDefaults.standard.string(forKey: "apple_geo") else {
                self.isError = true
                return
            }
            if (UIApplication.shared.canOpenURL(NSURL(string:"http://maps.apple.com")! as URL)) {
                guard let url = NSURL(string: s) as URL? else {
                    self.isError = true
                    return
                }
                UIApplication.shared.open(url)
            } else {
                NSLog("Can't use Apple Maps");
            }
        case 1:
            guard let s = UserDefaults.standard.string(forKey: "instagram") else {
                self.isError = true
                return
            }
            if let url = URL(string: s) {
                UIApplication.shared.open(url)
            }
        case 2:
            guard let s = UserDefaults.standard.string(forKey: "phone") else {
                self.isError = true
                return
            }
            if let phoneCallURL = URL(string: "telprompt://\(s)") {
                let application: UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallURL)) {
                    if #available(iOS 10.0, *) {
                        application.open(phoneCallURL, options: [:], completionHandler: nil)
                    } else {
                         application.openURL(phoneCallURL as URL)
                    }
                }
            }
        default:
            fatalError("Incorrect i")
        }
    }
}

struct MenuView: View {
    
    @EnvironmentObject var mc: ModelController
    
    @Binding var popupView: AnyView?
    @State private var yRange: [CGFloat] = [] // Координата y в исходной картинке текстуры верхней границы каждой из кнопок меню
    @State private var isAlert = false
    private let buttonHeight: CGFloat = 48
    private var maxY: CGFloat // Максимально возможная y в yRange
    
    private var menu: FetchedResults<Menu>
    private let modalPresentAction: ModalPresentAction
    
    var body: some View {
        VStack(spacing: 24) {
            LoyaltyCard(modalPresentAction: modalPresentAction, popupView: self.$popupView)
            ZStack {
                TextureBackground(y: 0, texture: .warm, blackout: .center)
                if mc.user?.discount != nil {
                    Text("Ваша скидка по карте: \(mc.user!.discount!)%")
                    .font(.SFUIDisplay(17))
                    .foregroundColor(.white)
                } else {
                    NativeLoading()
                }
            }.frame(height: self.buttonHeight)
            HStack(spacing: Figma.x(21)) {
                ForEach(0 ..< 3) { i in
                    GrayButton(i: i, isError: self.$isAlert)
                }
            }
            ForEach(menu, id: \.self) { element in
                Button(action: {
                    guard let uiImage = UIImage(data: (element as! Menu).image)
                    else {
                        self.isAlert = true
                        return
                    }
                    let modalVC = ImageZoomVC(image: uiImage, envSize: UIScreen.main.bounds.size)
                    self.modalPresentAction(
                        modalVC,
                        modalVC.preferredHeight,
                        false
                    )
                }) {
                    ZStack(alignment: .leading) {
                        TextureBackground(y: self.getY(id: Int((element as! Menu).id)))
                            .frame(height: self.buttonHeight)
                        Text((element as! Menu).title)
                            .font(.SFUIDisplay(18))
                            .padding(.horizontal, 31)
                            .foregroundColor(.white)
                    }
                }
            }
        }.padding(.horizontal)
        .onReceive(menu.publisher) { _ in
            DispatchQueue.main.async {
                self.yRange = Array(stride(from: self.buttonHeight, to: self.maxY, by: (self.maxY - self.buttonHeight) / CGFloat(self.menu.count)))
            }
        }
        .alert(isPresented: self.$isAlert) {
            Alert(title: Text("Ошибка"))
        }
    }
    
    // Возвращает координату y в текстуре для каждой кнопки по id. Служит для предотвращения ошибок с неправильным индексом в массиве
    private func getY(id: Int) -> CGFloat {
        if id < yRange.count {
            return yRange[id]
        } else {
            return 0
        }
    }
    
    init(
        _ popupView: Binding<AnyView?>,
        menu: FetchedResults<Menu>,
        modalPresentAction: @escaping ModalPresentAction
    ) {
        maxY = UIImage(named: "cold_texture")!.size.height - self.buttonHeight
        self._popupView = popupView
        self.menu = menu
        self.modalPresentAction = modalPresentAction
    }
}

//struct MenuView_Previews: PreviewProvider {
//    static var previews: some View {
//        MenuView()
//    }
//}
