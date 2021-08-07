//
//  ModalPresenting.swift
//  Cloud_53_ver2
//
//  Created by Андрей on 07.08.2021.
//  Copyright © 2021 oak. All rights reserved.
//

import UIKit

protocol ModalVCWithScrollView: UIViewController {
    var scrollViewPresentedOnModal: ScrollViewPresentedOnModal { get }
}

protocol ScrollViewPresentedOnModal: AnyObject {
    var isDragging: Bool { get }
    var gestureRecognizers: [UIGestureRecognizer]? { get }
    var contentOffset: CGPoint { get set }
}

extension UIScrollView: ScrollViewPresentedOnModal {}

extension UIViewController {
    func presentModal(
        _ vc: UIViewController,
        height: CGFloat,
        animated: Bool = true,
        isElastic: Bool = true,
        presentedScrollView: ScrollViewPresentedOnModal? = nil,
        completion: (() -> Void)? = nil
    ) {
        let delegate = ModalTransitioningDelegate(
            height: height,
            isElastic: isElastic,
            presentedScrollView: presentedScrollView
        )
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = delegate
        present(vc, animated: animated, completion: completion)
    }
    
    func presentModal(
        _ vc: ModalVCWithScrollView,
        height: CGFloat,
        animated: Bool = true,
        isElastic: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        presentModal(
            vc,
            height: height,
            animated: animated,
            isElastic: isElastic,
            presentedScrollView: vc.scrollViewPresentedOnModal,
            completion: completion
        )
    }
}

private final class ModalTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    private let height: CGFloat
    private let isElastic: Bool
    
    weak private var presentedScrollView: ScrollViewPresentedOnModal?
    
    init(height: CGFloat, isElastic: Bool, presentedScrollView: ScrollViewPresentedOnModal?) {
        self.height = height
        self.isElastic = isElastic
        self.presentedScrollView = presentedScrollView
        super.init()
    }
    
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        ModalPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            height: height,
            isElastic: isElastic,
            presentedScrollView: presentedScrollView
        )
    }
}

private final class ModalPresentationController: UIPresentationController {
    private enum DragDirection {
        case up
        case down
        
        init?(velocity: CGFloat) {
            switch velocity {
            case let velocity where velocity > 0:
                self = .down
            case let velocity where velocity < 0:
                self = .up
            default:
                return nil
            }
        }
    }
    
    private let height: CGFloat
    private let isElastic: Bool
    private var dimmingView: UIView?
    private var unnecessaryTranslation: CGFloat = 0
    
    weak private var presentedScrollView: ScrollViewPresentedOnModal?
    
    private var topGap: CGFloat {
        guard let container = containerView else { return .zero }
        return container.frame.height - height
    }
    
    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        height: CGFloat,
        isElastic: Bool,
        presentedScrollView: ScrollViewPresentedOnModal?
    ) {
        self.height = height
        self.isElastic = isElastic
        self.presentedScrollView = presentedScrollView
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(pan:)))
        recognizer.delegate = self
        presentedViewController.view.addGestureRecognizer(recognizer)
        presentedViewController.view.roundCorners(.top, radius: cornerRadius)
    }
    
    @objc private func didPan(pan: UIPanGestureRecognizer) {
        guard
            let view = pan.view,
            let superView = view.superview,
            let presented = presentedView
        else { return }
        
        let velocity = pan.velocity(in: superView).y
        let fullTranslation = pan.translation(in: superView).y
        let translation = fullTranslation - unnecessaryTranslation
        
        guard
            let dragDirection = DragDirection(velocity: velocity),
            canDrag(
                view: presented,
                currentTranslation: fullTranslation,
                dragDirection: dragDirection
            )
        else {
            guard pan.state == .ended || pan.state == .cancelled else { return }
            endDragging(translation: translation, velocity: nil)
            return
        }
        
        switch pan.state {
        case .changed:
            guard translation >= 0 else {
                guard isElastic else { return reset() }
                let elasticityHeight = pow(abs(translation), elasticityCoefficient)
                guard elasticityHeight + height <= superView.frame.height else { return }
                presented.frame.size.height = height + elasticityHeight
                presented.frame.origin.y = topGap - elasticityHeight
                return
            }
            presented.frame.origin.y = translation + topGap
            dimmingView?.alpha = 1 - translation / presented.frame.height
        case .ended, .cancelled:
            endDragging(translation: translation, velocity: velocity)
        default:
            break
        }
    }
    
    private func endDragging(translation: CGFloat, velocity: CGFloat?) {
        unnecessaryTranslation = 0
        let maxOffset = height * dismissOffsetCoefficient
        
        var isDismiss = translation > maxOffset
        if let velocity = velocity {
            isDismiss = isDismiss || velocity >= minVelocityForClosing
        }
        
        guard isDismiss else { return reset() }
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTap(_: Any) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    private func canDrag(
        view: UIView,
        currentTranslation: CGFloat,
        dragDirection: DragDirection
    ) -> Bool {
        guard let scrollView = presentedScrollView, scrollView.isDragging else { return true }
        let canDrag = view.frame.minY.rounded() > topGap.rounded()
            || dragDirection == .down && scrollView.contentOffset.y <= 0
        
        if canDrag {
            scrollView.contentOffset.y = 0
        } else {
            unnecessaryTranslation = currentTranslation
        }
        return canDrag
    }
    
    private func reset() {
        guard let presented = presentedView else { return }
        
        UIView.animate(
            withDuration: animationDuration,
            delay: .zero,
            options: [.curveEaseInOut, .allowUserInteraction],
            animations: { [self] in
                presented.frame = frameOfPresentedViewInContainerView
                presented.layoutIfNeeded()
                dimmingView?.alpha = 1
            }
        )
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let container = containerView else { return .zero }
        assert(
            container.frame.height >= height,
            "The height of the modal is greater than the height of the container"
        )
        
        return CGRect(
            x: 0,
            y: topGap,
            width: container.bounds.width,
            height: height
        )
    }
    
    override func presentationTransitionWillBegin() {
        guard
            let container = containerView,
            let coordinator = presentingViewController.transitionCoordinator
        else { return }
        
        let dimmingView = makeDimmingView(frame: container.bounds)
        self.dimmingView = dimmingView
        
        dimmingView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        )
        
        container.addSubview(dimmingView)
        dimmingView.addSubview(presentedViewController.view)
        
        coordinator.animate { context in
            dimmingView.alpha = 1
        }
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentingViewController.transitionCoordinator else { return }
        coordinator.animate { [dimmingView] _ in
            dimmingView?.alpha = 0
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        guard completed else { return }
        dimmingView?.removeFromSuperview()
    }
}

extension ModalPresentationController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        guard let scrollViewGestureRecognizers = presentedScrollView?.gestureRecognizers
        else { return false }
        
        return scrollViewGestureRecognizers.contains(otherGestureRecognizer)
    }
}

private func makeDimmingView(frame: CGRect) -> UIView {
    let view = UIView(frame: frame)
    view.backgroundColor = UIColor.black.withAlphaComponent(dimming)
    view.alpha = 0
    return view
}

// dismiss offset = modal screen height * dismissOffsetCoefficient
private let dismissOffsetCoefficient: CGFloat = 0.35

// elasticityHeight = translation ^ elasticityCoefficient
private let elasticityCoefficient: CGFloat = 0.5

private let animationDuration = 0.25
private let dimming: CGFloat = 0.5
private let cornerRadius: CGFloat = 20
private let minVelocityForClosing: CGFloat = 1250
