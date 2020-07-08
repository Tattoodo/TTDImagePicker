//
//  YPMenuItem.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 24/01/2018.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import UIKit

final class YPMenuItem: UIView { //TODO: - images
    
    var textLabel = UILabel()
    var button = UIButton()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    func setup() {
        backgroundColor = YPImagePickerConfiguration.shared.colors.bottomMenuItemBackgroundColor
        [textLabel, button].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        NSLayoutConstraint.activate([
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        textLabel.textAlignment = .center
        textLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        textLabel.textColor = YPImagePickerConfiguration.shared.colors.bottomMenuItemUnselectedTextColor
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.numberOfLines = 2
    }

    func select() {
        textLabel.textColor = YPImagePickerConfiguration.shared.colors.bottomMenuItemSelectedTextColor
    }

    func deselect() {
        textLabel.textColor = YPImagePickerConfiguration.shared.colors.bottomMenuItemUnselectedTextColor
    }
}
