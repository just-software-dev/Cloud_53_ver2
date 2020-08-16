//
//  SlideController.swift
//  Cloud 53
//
//  Created by Андрей on 30.06.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import SwiftUI

class SlideController: ObservableObject {
    
    @Published fileprivate var isReverse: Bool = false
    @Published private(set) var step = 0
    @Published fileprivate var steps: (Int?, Int?) = (0, nil)
    
    private func updateSteps(_ newStep: Int) {
        step = newStep
        withAnimation {
            steps = steps.0 == nil ? (newStep, nil) : (nil, newStep)
        }
    }
    
    func next() {
        isReverse = false
        updateSteps(step + 1)
    }
    
    func back() {
        isReverse = true
        updateSteps(step - 1)
    }
}

struct SlideView: View {
    
    unowned var slideController: SlideController
    var setView: (Int) -> AnyView
    
    var body: some View {
        ZStack {
            if slideController.steps.0 != nil {
                setTransition(setView(slideController.steps.0!))
            }
            if slideController.steps.1 != nil  {
                setTransition(setView(slideController.steps.1!))
            }
        }
    }
    
    private func setTransition(_ view: AnyView) -> some View {
        return view.transition(slideController.isReverse ? .slide: .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
    }
}
