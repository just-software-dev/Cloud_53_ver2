//
//  MainMenu.swift
//  Cloud 53
//
//  Created by Андрей on 08.07.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import SwiftUI

private struct FigmaTabBar: View {
    
    @Binding var selection: Int
    var images: [UIImage]
    
    var body: some View {
        HStack(spacing: Figma.x(5)) {
            ForEach(0 ..< self.images.count) { i in
                Image(uiImage: self.images[i])
                    .frame(width: 25, height: 25)
                    .padding(13)
                    .foregroundColor(i == self.selection ? Figma.red : Color.white)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.selection = i
                    }
            }
        }.padding(.horizontal, 20)
        .background(Blur(style: .dark))
        .cornerRadius(30)
    }
}

private struct MenuTitle: View {
    
    var title: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                FigmaTitle(text: title)
                Text(currentDate())
                    .font(.SFUIDisplay(16))
                    .foregroundColor(Figma.dateColor)
            }
            Spacer()
        }
    }
    
    func currentDate() -> String {
        let date = Date()
        let calendar = Calendar.current
        let weeknum = calendar.component(.weekday, from: date)
        let days = ["Воскресенье", "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"]
        let weekday = days[weeknum - 1]
        let day = calendar.component(.day, from: date)
        let mounths = ["января", "февраля", "марта", "апреля", "мая", "июня", "июля", "августа", "сентября", "октября", "ноября", "декабря"]
        let mounth = mounths[calendar.component(.month, from: date) - 1]
        return "\(weekday), \(day) \(mounth)"
    }
}

// Устанавливает заголовок, настраивает скрытие клавиатуры по нажатию на фон, при iOS < 14 добавляет пространство под контентом при появлении клавиатуры
private struct Standart: ViewModifier {
    
    var title: String
    
    func body(content: Content) -> some View {
        Group {
            if ProcessInfo().operatingSystemVersion.majorVersion < 14 {
                setView(content: content)
                    .modifier(BottomKeyboard())
            } else {
                setView(content: content)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.closeKeyboard()
        }
    }
    
    func setView(content: Content) -> some View {
        VStack(spacing: 0) {
            MenuTitle(title: title)
                .padding(EdgeInsets(top: 42, leading: 40, bottom: 29, trailing: 40))
            content
                .padding(.bottom, 110)
        }
    }
}

struct MainMenu: View {
    
    @ObservedObject private var keyboardResponder = KeyboardResponder()
    @State private var sections: [DiscountSection] = [] // Акции для раздела с акциями
    @State private var selection = 0
    @State private var popupView: AnyView? = nil // Текущее модальное окно (самописное)
    private let titles = ["Здравствуйте!", "Акции", "Парковка", "Аккаунт"]
    private let images: [UIImage] = [UIImage(named: "menu_icon")!, UIImage(named: "percent")!, UIImage(named: "p")!, UIImage(named: "person")!]
    private let modalPresentAction: ModalPresentAction
    
    @FetchRequest(fetchRequest: Menu.getAllItems()) var menu: FetchedResults<Menu> // Листы меню

    var body: some View {
        ZStack(alignment: .top) {
            Figma.darkGray
                .edgesIgnoringSafeArea(.all)
                .zIndex(1)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    if selection == 0 {
                        MenuView(self.$popupView, menu: self.menu, modalPresentAction: modalPresentAction)
                    } else if selection == 1 {
                        DiscountsView(sections: self.$sections, popupView: self.$popupView)
                    } else if selection == 2 {
                        ParkingView()
                    } else if selection == 3 {
                        AccountView()
                    }
                }.modifier(Standart(title: titles[selection]))
            }.zIndex(2)
            if keyboardResponder.keyboardHeight == 0 {
                VStack {
                    Spacer()
                    FigmaTabBar(selection: self.$selection, images: self.images)
                        .padding(.bottom, 27)
                }.zIndex(3)
            }
        }.presentPopupView(self.$popupView)
    }
    
    init(modalPresentAction: @escaping ModalPresentAction) {
        self.modalPresentAction = modalPresentAction
    }
}

// Фон для самописных модальных окон, при нажатии на который модальное окно исчезает
private struct TouchView: View {
    
    var whenReturn: () -> Void
    
    var body: some View {
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    self.whenReturn()
                }
            }
    }
}

private extension View {
    
    // Показ самописных модальных окон
    func presentPopupView(_ popup: Binding<AnyView?>) -> some View {
        ZStack {
            self.zIndex(1)
            if popup.wrappedValue != nil {
                Color.blackout(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(2)
                popup.wrappedValue!
                    .cornerRadius(30)
                    .padding(Figma.x(20))
                    .zIndex(3)
                TouchView(whenReturn: {popup.wrappedValue = nil})
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(4)
            }
        }
    }
}
