//
//  IntroView.swift
//  Cloud 53
//
//  Created by Андрей on 30.06.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import SwiftUI

private struct InformationView: SlidingView {
    
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
    
    @ObservedObject private var slideController = SlideController<InformationView>()
    @EnvironmentObject var mc: ModelController
    
    private let data = [(title: "Бесплатная паровка вашего авто!", image: "intro_car"),
                        (title: "Будь в курсе событий!", image: "intro_woman"),
                        (title: "Наслаждайся моментом!", image: "intro_fun")]
    
    var body: some View {
        ZStack(alignment: .top) {
            SlideView(slideController: self.slideController, whenFinished: {self.mc.endIntro()})
            VStack {
                Spacer()
                FigmaButton(text: "Далее", loading: false, type: .primary) {
                    self.slideController.next()
                }.padding(.bottom, 58)
            }
        }.padding(.horizontal, Figma.x(20))
        .onAppear() {
            self.slideController.content = self.data
        }
    }
}
