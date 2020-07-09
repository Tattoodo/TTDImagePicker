//
//  YPLibraryViewCell.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 2015/11/14.
//  Copyright © 2015 Yummypets. All rights reserved.
//

import UIKit

class YPMultipleSelectionIndicator: UIView {
    
    let circle = UIView()
    let label = UILabel()
    var selectionColor = UIColor.ypSystemBlue

    convenience init() {
        self.init(frame: .zero)
        let size: CGFloat = 20

        [circle, label].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        })
        NSLayoutConstraint.activate([
            circle.topAnchor.constraint(equalTo: topAnchor),
            circle.bottomAnchor.constraint(equalTo: bottomAnchor),
            circle.leadingAnchor.constraint(equalTo: leadingAnchor),
            circle.trailingAnchor.constraint(equalTo: trailingAnchor),
            circle.heightAnchor.constraint(equalToConstant: size),
            circle.widthAnchor.constraint(equalToConstant: size),

            label.widthAnchor.constraint(equalTo: widthAnchor),
            label.heightAnchor.constraint(equalTo: heightAnchor),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        circle.layer.cornerRadius = size / 2.0
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        set(number: nil)
    }
    
    func set(number: Int?) {
        label.isHidden = (number == nil)
        if let number = number {
            circle.backgroundColor = selectionColor
            circle.layer.borderColor = UIColor.clear.cgColor
            circle.layer.borderWidth = 0
            label.text = "\(number)"
        } else {
            circle.backgroundColor = UIColor.white.withAlphaComponent(0.3)
            circle.layer.borderColor = UIColor.white.cgColor
            circle.layer.borderWidth = 1
            label.text = ""
        }
    }
}

class YPLibraryViewCell: UICollectionViewCell {
    
    var representedAssetIdentifier: String!
    let imageView = UIImageView()
    let durationLabel = UILabel() //TODO: - add bg alpha color
    let selectionOverlay = UIView()
    let multipleSelectionIndicator = YPMultipleSelectionIndicator()
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        [imageView, durationLabel, selectionOverlay, multipleSelectionIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            selectionOverlay.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectionOverlay.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            selectionOverlay.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectionOverlay.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            durationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),

            multipleSelectionIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            multipleSelectionIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -3)
        ])
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 4
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        durationLabel.textColor = .white
        durationLabel.font = .systemFont(ofSize: 12)
        durationLabel.isHidden = true
        selectionOverlay.backgroundColor = .white
        selectionOverlay.alpha = 0
        backgroundColor = .ypSecondarySystemBackground
    }

    override var isSelected: Bool {
        didSet { refreshSelection() }
    }
    
    override var isHighlighted: Bool {
        didSet { refreshSelection() }
    }
    
    private func refreshSelection() {
        let showOverlay = isSelected || isHighlighted
        selectionOverlay.alpha = showOverlay ? 0.6 : 0
    }
}
