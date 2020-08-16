//
//  IntroView.swift
//  Cloud 53
//
//  Created by Андрей on 30.06.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import SwiftUI

private struct InformationView: View {
    
    var data: (title: String, image: String)
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    FigmaTitle(text: data.title)
                        .padding(.top, Figma.y(46))
                    Spacer()
                }
                Spacer()
            }
            Image(data.image)
                .resizable()
                .scaledToFit()
                .padding(.horizontal)
        }
    }
}

struct IntroView: View {
    
    @ObservedObject private var slideController = SlideController()
    @EnvironmentObject var mc: ModelController
    
    private let data = [(title: "Бесплатная паровка вашего авто!", image: "intro_car"),
                        (title: "Будь в курсе событий!", image: "intro_woman"),
                        (title: "Наслаждайся моментом!", image: "intro_fun")]
    
    var body: some View {
        ZStack(alignment: .top) {
            SlideView(slideController: self.slideController) { step in
                return AnyView(InformationView(data: self.data[step]))
            }
            VStack {
                Spacer()
                Button(action: {self.tap()}) {
                    FigmaButtonView(text: "Далее", loading: false, type: .primary)
                }.padding(.bottom, 58)
            }
        }.padding(.horizontal, Figma.x(20))
    }
    
    private func tap() {
        if slideController.step == data.count - 1 {
            mc.endIntro()
        } else {
            slideController.next()
        }
    }
}

//struct IntroView_Previews: PreviewProvider {
//    static var previews: some View {
//        IntroView()
//    }
//}
