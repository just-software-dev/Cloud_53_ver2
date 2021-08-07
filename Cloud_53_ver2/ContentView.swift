//
//  ContentView.swift
//  Cloud 53
//
//  Created by Андрей on 29.06.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var mc: ModelController
    private let modalPresentAction: ModalPresentAction
    
    var body: some View {
        NavigationView {
            ZStack {
                if mc.currentSection == .intro {
                    IntroView()
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                } else if mc.currentSection == .auth {
                    LoginPage()
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                } else if mc.currentSection == .menu {
                    MainMenu(modalPresentAction: modalPresentAction)
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }.hideNavigationBar()
        }
    }
    
    init(modalPresentAction: @escaping ModalPresentAction) {
        self.modalPresentAction = modalPresentAction
    }
}
