//
//  YPFilterCollectionViewCell.swift
//  photoTaking
//
//  Created by Sacha Durand Saint Omer on 21/10/16.
//  Copyright © 2016 octopepper. All rights reserved.
//

import UIKit

class YPFilterCollectionViewCell: UICollectionViewCell {

    let name = UILabel()
    let imageView = UIImageView()
    override var isHighlighted: Bool { didSet {
        UIView.animate(withDuration: 0.1) {
            self.contentView.transform = self.isHighlighted
                ? CGAffineTransform(scaleX: 0.95, y: 0.95)
                : CGAffineTransform.identity
        }
        }
    }
    override var isSelected: Bool {
        didSet {
            name.textColor = isSelected
                ? UIColor.ypLabel
                : UIColor.ypSecondaryLabel
            name.font = .systemFont(
                ofSize: 11,
                weight: isSelected ? .semibold : .regular
            )
        }
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        [name, imageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            name.topAnchor.constraint(equalTo: topAnchor),
            name.trailingAnchor.constraint(equalTo: trailingAnchor),
            name.leadingAnchor.constraint(equalTo: leadingAnchor),

            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        name.font = .systemFont(ofSize: 11, weight: UIFont.Weight.regular)
        name.textColor = UIColor.ypSecondaryLabel
        name.textAlignment = .center

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.ypLabel.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 4, height: 7)
        self.layer.shadowRadius = 5
        self.layer.backgroundColor = UIColor.clear.cgColor
    }
}
