//
//  LoyaltyCardVC.swift
//  Cloud_53_ver2
//
//  Created by Андрей on 07.08.2021.
//  Copyright © 2021 oak. All rights reserved.
//

import UIKit

class InstructionVC: UIViewController, ModalVCWithScrollView {
    private let instructionTitle = "Накопительная карта гостя"
    private let instructionDescription: String = UserDefaults.standard.string(forKey: "loyalty") ?? ""
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView().autoLayout()
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    var scrollViewPresentedOnModal: ScrollViewPresentedOnModal {
        scrollView
    }
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel().autoLayout()
        view.font = .SFUIDisplay(24)
        view.text = instructionTitle
        view.numberOfLines = 2
        return view
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let view = UILabel().autoLayout()
        view.font = .SFUIDisplay(16)
        view.text = instructionDescription
        view.numberOfLines = 0
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView().autoLayout()
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        
        titleLabel.centerX()
        titleLabel.width(Figma.x(309))
        titleLabel.top(gap: Figma.y(39))
        
        descriptionLabel.centerX()
        descriptionLabel.top(gap: 14, anchor: titleLabel.bottomAnchor)
        descriptionLabel.width(Figma.x(309))
        descriptionLabel.bottom(gap: Figma.y(54))
        return view
    }()
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = Figma.darkGrayUI
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.layout()
        contentView.centerX()
        contentView.layout()
    }
}
