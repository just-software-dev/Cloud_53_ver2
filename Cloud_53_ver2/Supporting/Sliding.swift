//
//  SlideController.swift
//  Cloud 53
//
//  Created by Андрей on 30.06.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import SwiftUI
import Combine

protocol SlidingView: View {
    
    associatedtype InitData
    
    var data: InitData { get set }
    
    init(data: InitData)
}

// 0 - whenRetuned
// 1 - active
// 2 - whenFinished
private class Activity: NSObject {
    
    @objc dynamic var value: Int
    
    init(_ value: Int) {
        self.value = value
        super.init()
    }
}

class SlideController<SomeView: SlidingView>: ObservableObject {
    
    @Published fileprivate var isActive = Activity(1)
    @Published fileprivate var views: [SomeView?] = [nil, nil]
    @Published fileprivate var isReverse: Bool = false
    @Published private(set) var step = 0
    @Published private var content_: [SomeView.InitData] = []
    
    var content: [SomeView.InitData] {
        get {
            return self.content_
        }
        set(value) {
            self.content_ = value
            updateViews()
        }
    }
    
    func next() {
        if self.step + 1 < self.content.count {
            self.step += 1
            self.isReverse = false
            withAnimation {
                updateViews()
            }
        } else {
            self.isActive.value = 2
        }
    }
    
    func back() {
        if self.step > 0 {
            self.step -= 1
            self.isReverse = true
            withAnimation {
                updateViews()
            }
        } else {
            self.isActive.value = 0
        }
    }
    
    private func updateViews() {
        let array = [SomeView(data: content[step]), nil]
        self.views = step % 2 == 0 ? array : array.reversed()
    }
}

struct SlideView<SomeView: SlidingView>: View {
    
    @ObservedObject var slideController: SlideController<SomeView>
    var whenReturned: (() -> Void)?
    var whenFinished: (() -> Void)?
    
    @State private var observer: NSKeyValueObservation?
    
    var body: some View {
        ZStack {
            if slideController.views[0] != nil {
                setTransition(slideController.views[0]!)
            }
            if slideController.views[1] != nil {
                setTransition(slideController.views[1]!)
            }
        }.onAppear() {
            self.observer = self.slideController.isActive.observe(\.value, options: .new) { active, change in
                guard let new = change.newValue else {return}
                if new == 0 {
                    if let whenReturned = self.whenReturned {
                        whenReturned()
                    }
                } else if new == 2 {
                    if let whenFinished = self.whenFinished {
                        whenFinished()
                    }
                }
            }
        }
    }
    
    private func setTransition(_ view: SomeView) -> some View {
        return view.transition(slideController.isReverse ? .slide: .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
    }
}
