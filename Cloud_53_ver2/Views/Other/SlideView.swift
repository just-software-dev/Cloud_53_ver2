//
//  SlideController.swift
//  Cloud 53
//
//  Created by Андрей on 30.06.2020.
//  Copyright © 2020 oak. All rights reserved.
//
// Аналог UIPageView

import SwiftUI

class SlideController: ObservableObject {

    @Published fileprivate var steps: [Int] = [0, 0]
    @Published fileprivate var flag: Bool = false
    @Published fileprivate var isReverse: Bool = false
    
    private(set) var step: Int {
        get {
            return steps[flag ? 1 : 0]
        }
        set {
            steps[flag ? 1 : 0] = newValue
        }
    }
    
    var length: Int
    var onReturned: (() -> Void)?
    var onFinished: (() -> Void)?
    
    init(_ length: Int) {
        self.length = length
    }
    
    func next() {
        let prevStep = step
        if prevStep == length - 1 {
            onFinished?()
            return
        }
        isReverse = false
        withAnimation {
            flag.toggle()
            step = prevStep + 1
        }
    }
    
    func back() {
        let prevStep = step
        if prevStep == 0 {
            onReturned?()
            return
        }
        isReverse = true
        withAnimation {
            flag.toggle()
            step = prevStep - 1
        }
    }
}

struct SlideView<Content: View>: View {
    
    @ObservedObject var slideController: SlideController
    var content: (Int) -> Content
    
    var body: some View {
        ZStack {
            if slideController.flag {
                setTransition(content(slideController.steps[1]))
            }
            if !slideController.flag {
                setTransition(content(slideController.steps[0]))
            }
        }
    }
    
    private func setTransition(_ view: Content) -> some View {
        return view.transition(slideController.isReverse ? .slide: .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
    }
}
