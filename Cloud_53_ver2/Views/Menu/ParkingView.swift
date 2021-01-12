//
//  ParkingView.swift
//  Cloud 53
//
//  Created by Андрей on 08.07.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import SwiftUI
import FirebaseAuth

private struct ParkingData: Encodable {
    var car_brand: String
    var car: String
    var phone: String
    var uid: String
}

struct ParkingView: View {
    
    @EnvironmentObject var mc: ModelController
    
    @State private var carBrand = ""
    @State private var carNumber = ""
    @State private var phone = Auth.auth().currentUser?.phoneNumber ?? ""
    @State private var message: String?
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            FigmaTextField(text: "Марка машины", input: self.$carBrand, maxLength: 30)
                .padding(.bottom, 15)
            FigmaTextField(text: "Номер машины", input: self.$carNumber, maxLength: 9)
                .padding(.bottom, 15)
            FigmaTextField.phone(input: self.$phone)
                .padding(.bottom, 33)
            FigmaButton(text: "Заказать парковку", loading: self.isLoading, type: .primary) {
                self.request()
            }
            Message(text: self.message, defaultHeight: 44)
        }.padding(EdgeInsets(top: 35, leading: 23, bottom: 0, trailing: 23))
        .background(Figma.gray.cornerRadius(30))
        .padding(.horizontal)
        .onAppear() {
            guard let user = self.mc.user else {return}
            self.carBrand = user.carBrand
            self.carNumber = user.car
        }
    }
    
    private func request() {
        self.changeMessage(nil)
        self.isLoading = true
        self.mc.setCarNumber(self.carNumber)
        self.mc.setCarBrand(self.carBrand)
        let data = ParkingData(car_brand: self.carBrand, car: self.carNumber, phone: self.phone, uid: Auth.auth().currentUser!.uid)
        DataMonitoring.shareInstance.get(path: "information/parking/link") { (snapshot) in
            DispatchQueue.main.async {
                guard let link = snapshot.value as? String
                else {
                    self.changeMessage("Данная функция временно недоступна")
                    self.isLoading = false
                    return
                }
                MyHTTP.POST(url: link, data: data) { result in
                    self.isLoading = false
                    switch result {
                    case .success(let data):
                        self.changeMessage(String(decoding: data, as: UTF8.self))
                    case .failure(let error):
                        self.changeMessage(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func changeMessage(_ text: String?) {
        withAnimation {
            message = text
        }
    }
}

//struct ParkingView_Previews: PreviewProvider {
//    static var previews: some View {
//        ParkingView()
//    }
//}
