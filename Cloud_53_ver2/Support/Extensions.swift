//
//  Extensions.swift
//  Cloud 53
//
//  Created by Андрей on 29.06.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import SwiftUI

extension Color {
    
    static func blackout(_ alpha: CGFloat) -> Color {
        return Color(UIColor(red: 0, green: 0, blue: 0, alpha: alpha))
    }
}

extension View {
    
    func hideNavigationBar() -> some View {
        self
            .navigationBarTitle("")
            .navigationBarHidden(true)
    }
}

extension Font {

    static func SFUIDisplay(_ size: CGFloat) -> Font {
        return .custom("SF UI Display", size: size)
    }
    
    static func SFProDisplay(_ size: CGFloat) -> Font {
        return .custom("SF Pro Display Bold", size: size)
    }
}

extension UIFont {
    
    static func SFUIDisplay(_ size: CGFloat) -> UIFont {
        UIFont(name: "SF UI Display", size: size)!
    }
    
    static func SFProDisplay(_ size: CGFloat) -> UIFont {
        UIFont(name: "SF Pro Display Bold", size: size)!
    }
}

extension UIApplication {
    
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func getSafeAreaSize(_ alignment: Alignment) -> CGFloat {
        guard let windowScene = connectedScenes.first as? UIWindowScene, let sceneDelegate = windowScene.delegate as? SceneDelegate
        else {
          return 0
        }
        guard let window = sceneDelegate.window else {return 0}
        switch alignment {
            case .top:
                return window.safeAreaInsets.top
            case .bottom:
                return window.safeAreaInsets.bottom
            case .leading:
                return window.safeAreaInsets.left
            case .trailing:
                return window.safeAreaInsets.right
            default:
                fatalError("Incorrect alignment")
        }
    }
}

extension CACornerMask {
    public static let top: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    public static let bottom: CACornerMask = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    public static let left: CACornerMask = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    public static let right: CACornerMask = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    public static let all: CACornerMask = [
        .layerMinXMinYCorner,
        .layerMaxXMinYCorner,
        .layerMinXMaxYCorner,
        .layerMaxXMaxYCorner
    ]
}

extension UIView {
    public func roundCorners(_ corners: CACornerMask = .all, radius: CGFloat) {
        clipsToBounds = true
        layer.cornerRadius = radius
        layer.maskedCorners = corners
    }
}

extension UIImage {
    func getFrame(for envSize: CGSize) -> CGRect {
        var scale: CGFloat = 0
        if size.height / size.width > envSize.height / envSize.width {
            scale = envSize.height / size.height
        } else {
            scale = envSize.width / size.width
        }
        return CGRect(x: 0, y: 0, width: size.width * scale, height: size.height * scale)
    }
}
