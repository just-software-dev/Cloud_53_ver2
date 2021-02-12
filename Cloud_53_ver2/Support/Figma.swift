//
//  Figma.swift
//  Cloud 53
//
//  Created by Андрей on 29.06.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import SwiftUI

final class Figma {
    
    static let red = Color(UIColor(red: 0.937, green: 0.118, blue: 0.137, alpha: 1))
    static let gray = Color(UIColor(red: 0.102, green: 0.106, blue: 0.118, alpha: 1))
    static let darkGray = Color(UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1))
    static let dateColor = Color(UIColor(red: 0.55, green: 0.55, blue: 0.55, alpha: 1))
    static let lightGray = Color(UIColor(red: 0.832, green: 0.832, blue: 0.832, alpha: 1))
    
    static let ratioX = UIScreen.main.bounds.width / 375
    static let ratioY = UIScreen.main.bounds.height / 667
    
    static func x(_ size: CGFloat) -> CGFloat {
        return size * ratioX
    }
    
    static func y(_ size: CGFloat) -> CGFloat {
        return size * ratioY
    }
}
