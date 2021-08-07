//
//  DiscountsView.swift
//  Cloud 53
//
//  Created by Андрей on 08.07.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import SwiftUI

private let discountWidth: CGFloat = Figma.x(158)
private let spaceWidth: CGFloat = Figma.x(20)
private var bigWidth: CGFloat {
    get {
        return discountWidth * 2 + spaceWidth
    }
}

// Описание акции
private struct DiscountSheet: View {
    
    var text: String
    
    var body: some View {
        Text(text).font(.SFUIDisplay(16))
            .minimumScaleFactor(0.9)
            .padding(EdgeInsets(top: Figma.y(35), leading: Figma.x(22), bottom: Figma.y(35), trailing: Figma.x(22)))
            .frame(width: Figma.x(246))
            .background(Color.black)
    }
}

private struct DiscountCell: View {
    
    var image: UIImage
    var title: String
    var description: String
    @Binding var popupView: AnyView?
    
    var body: some View {
        Button(action: {
            withAnimation {
                self.popupView = AnyView(DiscountSheet(text: self.description))
            }
        }) {
            VStack(alignment: .leading, spacing: 7) {
                Image(uiImage: self.image)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(30)
                Text(self.title).font(.SFUIDisplay(16))
                    .foregroundColor(.white)
            }
        }
    }
}

private struct DiscountColumn: View {
    
    var list: [Discount]
    @Binding var popupView: AnyView?
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(self.list) { discount in
                DiscountCell(image: discount.image, title: discount.title, description: discount.description, popupView: self.$popupView)
            }
        }.frame(width: discountWidth)
    }
}

struct Discount: Identifiable {
    var id = UUID()
    var image: UIImage
    var title: String
    var description: String
    var big: Bool
}

struct DiscountSection: Identifiable {
    var id = UUID()
    var leftColumn: [Discount]
    var rightColumn: [Discount]
    var bigDiscount: Discount?
}

struct DiscountsView: View {
    
    @EnvironmentObject var mc: ModelController
    
    @Binding var sections: [DiscountSection]
    @Binding var popupView: AnyView?
    @State private var data: [Discount] = []
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(self.sections) { section in
                HStack(alignment: .top, spacing: spaceWidth) {
                    DiscountColumn(list: section.leftColumn, popupView: self.$popupView)
                    DiscountColumn(list: section.rightColumn, popupView: self.$popupView)
                }
                if section.bigDiscount != nil {
                    DiscountCell(image: section.bigDiscount!.image, title: section.bigDiscount!.title, description: section.bigDiscount!.description, popupView: self.$popupView)
                        .frame(width: bigWidth)
                } else {
                    Spacer().frame(width: 0, height: 0)
                }
            }
        }.onReceive(self.mc.coreDataHelper.$promoUpdate) { new in
            DispatchQueue.main.async {
                self.update()
            }
        }
    }
    
    // Загрузка акций. Не используется FetchRequest, так как перед установкой акций их необходимо распределить по колонкам
    private func update() {
        var data: [Discount] = []
        for e in self.mc.coreDataHelper.getPromoList() ?? [] {
            data.append(Discount(image: UIImage(data: e.image) ?? UIImage(named: "example")!, title: e.title, description: e.text, big: e.big))
        }
        self.sort(data)
    }
    
    // Сортировка акций по размеру и установка их на экране
    private func sort(_ data: [Discount]) {
        self.sections = []
        var leftSum: CGFloat = 0
        var rightSum: CGFloat = 0
        var leftColumn: [Discount] = []
        var rightColumn: [Discount] = []
        for e in data {
            if !e.big {
                if leftSum <= rightSum {
                    leftColumn.append(e)
                    leftSum += e.image.size.height
                } else {
                    rightColumn.append(e)
                    rightSum += e.image.size.height
                }
            } else {
                leftSum = 0
                rightSum = 0
                sections.append(DiscountSection(leftColumn: leftColumn, rightColumn: rightColumn, bigDiscount: e))
                leftColumn = []
                rightColumn = []
            }
        }
        if leftColumn.count > 0 || rightColumn.count > 0 {
            sections.append(DiscountSection(leftColumn: leftColumn, rightColumn: rightColumn))
        }
    }
}

//struct DiscountsView_Previews: PreviewProvider {
//    static var previews: some View {
//        DiscountsView()
//    }
//}
