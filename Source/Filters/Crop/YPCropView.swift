//
//  YPCropView.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 12/02/2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import UIKit

extension UIImage {
    var aspectRatio: CGFloat {
        size.width &/ size.height
    }
}
class YPCropView: UIView {
    private var originalImageAspectRatio: CGFloat!
    private var originalImage: UIImage!
    let imageView = UIImageView()
    let topCurtain = UIView()
    let cropArea = UIView()
    let bottomCurtain = UIView()
    let leftCurtain = UIView()
    let rightCurtain = UIView()
    let bordersView = UIView()
    let toolbar = CropToolbarMenu()

    convenience init(image: UIImage) {
        self.init(frame: .zero)
        setupViewHierarchy()
        originalImageAspectRatio = image.aspectRatio
        setupLayout(with: image, ratio: toolbar.selectedApsectRatio.aspectRatio ?? originalImageAspectRatio)
        applyStyle()
        imageView.image = image
        originalImage = image
        toolbar.onAspectRatioChange = { [weak self] aspect in
            self?.apply(aspectRatio: aspect)
        }
    }
    
    private func setupViewHierarchy() {
        [imageView, leftCurtain, topCurtain, cropArea, rightCurtain, bottomCurtain, toolbar, bordersView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
    
    private func setupLayout(with image: UIImage, ratio: CGFloat) {
        let margin: CGFloat = 18
        let r: CGFloat = CGFloat(1.0 / ratio)
        NSLayoutConstraint.activate([
            topCurtain.topAnchor.constraint(equalTo: topAnchor),
            topCurtain.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
            topCurtain.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin),

            leftCurtain.leadingAnchor.constraint(equalTo: leadingAnchor),
            leftCurtain.topAnchor.constraint(equalTo: topAnchor),
            leftCurtain.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
            leftCurtain.widthAnchor.constraint(equalToConstant: margin),

            cropArea.topAnchor.constraint(equalTo: topCurtain.bottomAnchor),
            cropArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
            cropArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin),

            bottomCurtain.topAnchor.constraint(equalTo: cropArea.bottomAnchor),
            bottomCurtain.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
            bottomCurtain.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin),
            bottomCurtain.bottomAnchor.constraint(equalTo: toolbar.topAnchor),

            rightCurtain.trailingAnchor.constraint(equalTo: trailingAnchor),
            rightCurtain.topAnchor.constraint(equalTo: topAnchor),
            rightCurtain.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
            rightCurtain.widthAnchor.constraint(equalToConstant: margin),

            toolbar.leadingAnchor.constraint(equalTo: leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: bottomAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: safeAreaInsets.bottom + 60 + 24),

            cropArea.heightAnchor.constraint(equalTo: cropArea.widthAnchor, multiplier: r),
            cropArea.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -24),

            bordersView.leadingAnchor.constraint(equalTo: leftCurtain.trailingAnchor),
            bordersView.topAnchor.constraint(equalTo: topCurtain.bottomAnchor),
            bordersView.bottomAnchor.constraint(equalTo: bottomCurtain.topAnchor),
            bordersView.trailingAnchor.constraint(equalTo: rightCurtain.leadingAnchor)
        ])

        // Fit image differently depnding on its ratio.
        let imageRatio: CGFloat = image.size.width / image.size.height
        if ratio > imageRatio {
            let scaledDownRatio = UIScreen.main.bounds.width / image.size.width
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: image.size.width * scaledDownRatio),
                imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
                imageView.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
        } else if ratio < imageRatio {
            NSLayoutConstraint.activate([
                imageView.heightAnchor.constraint(equalTo: cropArea.heightAnchor),
                imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
                imageView.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: cropArea.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: cropArea.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: cropArea.trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: cropArea.bottomAnchor)
            ])
        }
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: CGFloat(imageRatio)).isActive = true
    }

    private func apply(aspectRatio: CropAspect) {
        [imageView, topCurtain, cropArea, bottomCurtain, rightCurtain, leftCurtain, bordersView, toolbar].forEach { $0.removeFromSuperview() }
        [imageView, topCurtain, cropArea, bottomCurtain, rightCurtain, leftCurtain, bordersView].forEach { NSLayoutConstraint.deactivate($0.constraints) }
        setupViewHierarchy()
        setupLayout(with: originalImage, ratio: aspectRatio.aspectRatio ?? originalImageAspectRatio)
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }

    private func applyStyle() {
        backgroundColor = .ypSystemBackground
        clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.isMultipleTouchEnabled = true
        cropArea.backgroundColor = .clear
        cropArea.isUserInteractionEnabled = false

        curtainStyle(v: topCurtain)
        curtainStyle(v: bottomCurtain)
        curtainStyle(v: leftCurtain)
        curtainStyle(v: rightCurtain)

        bordersView.backgroundColor = .clear
        bordersView.layer.borderWidth = 1
        bordersView.layer.borderColor = UIColor.white.cgColor
        bordersView.isUserInteractionEnabled = false

        toolbar.backgroundColor = .ypSystemBackground
    }
    
    func curtainStyle(v: UIView) {
        v.backgroundColor = UIColor.ypSystemBackground.withAlphaComponent(0.7)
        v.isUserInteractionEnabled = false
    }
}
