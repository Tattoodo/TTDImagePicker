//
//  YPPagerMenu.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 24/01/2018.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import UIKit

final class YPPagerMenu: UIView { //TODO: selected segment control
    
    var didSetConstraints = false
    var menuItems = [YPMenuItem]()
    
    convenience init() {
        self.init(frame: .zero)
        backgroundColor = .offWhiteOrBlack
        clipsToBounds = true
    }
    
    var separators = [UIView]()
    
    func setUpMenuItemsConstraints() {
        let menuItemWidth: CGFloat = UIScreen.main.bounds.width / CGFloat(menuItems.count)
        var previousMenuItem: YPMenuItem?
        for m in menuItems {
            m.translatesAutoresizingMaskIntoConstraints = false
            addSubview(m)

            NSLayoutConstraint.activate([
                m.topAnchor.constraint(equalTo: topAnchor),
                m.bottomAnchor.constraint(equalTo: bottomAnchor),
                m.widthAnchor.constraint(equalToConstant: menuItemWidth)
            ])
            
            m.fillVertically().width(menuItemWidth)
            if let pm = previousMenuItem {
                NSLayoutConstraint.activate([ m.leadingAnchor.constraint(equalTo: pm.trailingAnchor, constant: 0)])
            } else {
                NSLayoutConstraint.activate([  m.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)])
            }
            
            previousMenuItem = m
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        if !didSetConstraints {
            setUpMenuItemsConstraints()
        }
        didSetConstraints = true
    }
    
    func refreshMenuItems() {
        didSetConstraints = false
        updateConstraints()
    }
}
