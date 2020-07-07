//
//  YPGridView.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 15/11/2016.
//  Copyright © 2016 Yummypets. All rights reserved.
//

class YPGridView: UIView {
    
    let line1 = UIView()
    let line2 = UIView()
    let line3 = UIView()
    let line4 = UIView()
    
    convenience init() {
        self.init(frame: .zero)
        isUserInteractionEnabled = false
        let stroke: CGFloat = 0.5

        [line1, line2, line3, line4].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = UIColor.white.withAlphaComponent(0.6)
            applyShadow(to: $0)
            addSubview($0)
        }

        [line1, line2].enumerated().forEach {
            let numberInArray = CGFloat($0.offset) + 1.0
            let view = $0.element
            view.widthAnchor.constraint(equalToConstant: stroke).isActive = true
            let constraint = NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: numberInArray == 1 ? 0.77 : 1.33, constant: 0)
            constraint.isActive = true
            view.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        }

        [line3, line4].enumerated().forEach {
            let numberInArray = CGFloat($0.offset) + 1.0
            let view = $0.element
            view.heightAnchor.constraint(equalToConstant: stroke).isActive = true
            let constraint = NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: numberInArray == 1 ? 0.77 : 1.33, constant: 0)
            constraint.isActive = true
            view.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        }
    }
    
    func applyShadow(to view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 2
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
}
