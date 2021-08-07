//
//  AutoLayout.swift
//  Cloud_53_ver2
//
//  Created by Андрей on 07.08.2021.
//  Copyright © 2021 oak. All rights reserved.
//

import UIKit

enum Edge {
    case top
    case bottom
    case left
    case right
}

extension Set where Element == Edge {
    static let all: Set<Edge> = Set(arrayLiteral: .top, .bottom, .left, .right)
    static let vertical: Set<Edge> = Set(arrayLiteral: .top, .bottom)
    static let horizontal: Set<Edge> = Set(arrayLiteral: .left, .right)
    
    static let topLeft: Set<Edge> = Set(arrayLiteral: .top, .left)
    static let topRight: Set<Edge> = Set(arrayLiteral: .top, .right)
    static let bottomRight: Set<Edge> = Set(arrayLiteral: .bottom, .right)
    static let bottomLeft: Set<Edge> = Set(arrayLiteral: .bottom, .left)
}

extension NSLayoutConstraint {
    func activated() -> NSLayoutConstraint {
        self.isActive = true
        return self
    }
}

extension UIView {
    @discardableResult
    func top(offset: CGFloat = 0, anchor: NSLayoutYAxisAnchor? = nil) -> NSLayoutConstraint {
        precondition(!translatesAutoresizingMaskIntoConstraints, autoLayoutIsDisabledError)
        return self.topAnchor.constraint(
            equalTo: anchor ?? self.superview!.topAnchor,
            constant: offset
        ).activated()
    }
    
    @discardableResult
    func bottom(offset: CGFloat = 0, anchor: NSLayoutYAxisAnchor? = nil) -> NSLayoutConstraint {
        precondition(!translatesAutoresizingMaskIntoConstraints, autoLayoutIsDisabledError)
        return self.bottomAnchor.constraint(
            equalTo: anchor ?? self.superview!.bottomAnchor,
            constant: offset
        ).activated()
    }
    
    @discardableResult
    func left(offset: CGFloat = 0, anchor: NSLayoutXAxisAnchor? = nil) -> NSLayoutConstraint {
        precondition(!translatesAutoresizingMaskIntoConstraints, autoLayoutIsDisabledError)
        return self.leadingAnchor.constraint(
            equalTo: anchor ?? self.superview!.leadingAnchor,
            constant: offset
        ).activated()
    }
    
    @discardableResult
    func right(offset: CGFloat = 0, anchor: NSLayoutXAxisAnchor? = nil) -> NSLayoutConstraint {
        precondition(!translatesAutoresizingMaskIntoConstraints, autoLayoutIsDisabledError)
        return self.trailingAnchor.constraint(
            equalTo: anchor ?? self.superview!.trailingAnchor,
            constant: offset
        ).activated()
    }
    
    @discardableResult
    func width(_ constant: CGFloat) -> NSLayoutConstraint {
        precondition(!translatesAutoresizingMaskIntoConstraints, autoLayoutIsDisabledError)
        return self.widthAnchor.constraint(equalToConstant: constant).activated()
    }
    
    @discardableResult
    func height(_ constant: CGFloat) -> NSLayoutConstraint {
        precondition(!translatesAutoresizingMaskIntoConstraints, autoLayoutIsDisabledError)
        return self.heightAnchor.constraint(equalToConstant: constant).activated()
    }
    
    @discardableResult
    func centerY(offset: CGFloat = 0, anchor: NSLayoutYAxisAnchor? = nil) -> NSLayoutConstraint {
        precondition(!translatesAutoresizingMaskIntoConstraints, autoLayoutIsDisabledError)
        return self.centerYAnchor.constraint(
            equalTo: anchor ?? self.superview!.centerYAnchor,
            constant: offset
        ).activated()
    }
    
    @discardableResult
    func centerX(offset: CGFloat = 0, anchor: NSLayoutXAxisAnchor? = nil) -> NSLayoutConstraint {
        precondition(!translatesAutoresizingMaskIntoConstraints, autoLayoutIsDisabledError)
        return self.centerXAnchor.constraint(
            equalTo: anchor ?? self.superview!.centerXAnchor,
            constant: offset
        ).activated()
    }
}

extension UIView {
    @discardableResult
    func top(gap: CGFloat, anchor: NSLayoutYAxisAnchor? = nil) -> NSLayoutConstraint {
        top(offset: gap, anchor: anchor)
    }
    
    @discardableResult
    func bottom(gap: CGFloat, anchor: NSLayoutYAxisAnchor? = nil) -> NSLayoutConstraint {
        bottom(offset: -gap, anchor: anchor)
    }
    
    @discardableResult
    func left(gap: CGFloat, anchor: NSLayoutXAxisAnchor? = nil) -> NSLayoutConstraint {
        left(offset: gap, anchor: anchor)
    }
    
    @discardableResult
    func right(gap: CGFloat, anchor: NSLayoutXAxisAnchor? = nil) -> NSLayoutConstraint {
        right(offset: -gap, anchor: anchor)
    }
    
    func size(_ size: CGSize) {
        width(size.width)
        height(size.height)
    }
    
    func center(relative view: UIView? = nil) {
        self.centerX(anchor: view?.centerXAnchor)
        self.centerY(anchor: view?.centerYAnchor)
    }
    
    @discardableResult
    func layout(
        _ edge: Edge,
        gap: CGFloat = 0,
        relative view: UIView? = nil
    ) -> NSLayoutConstraint {
        switch edge {
        case .top:
            return top(gap: gap, anchor: view?.topAnchor)
        case .bottom:
            return bottom(gap: gap, anchor: view?.bottomAnchor)
        case .left:
            return left(gap: gap, anchor: view?.leadingAnchor)
        case .right:
            return right(gap: gap, anchor: view?.trailingAnchor)
        }
    }
    
    func layout(_ edges: Set<Edge> = .all, gap: CGFloat = 0, relative view: UIView? = nil) {
        edges.forEach { layout($0, gap: gap, relative: view) }
    }
    
    @discardableResult
    func autoLayout() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}

private let autoLayoutIsDisabledError = "Auto layout is disabled. Set translatesAutoresizingMaskIntoConstraints = false or .autoLayout() to fix it"
