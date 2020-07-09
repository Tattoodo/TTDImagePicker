//
//  YPCropView.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 12/02/2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import UIKit

class YPCropView: UIView {
    
    let imageView = UIImageView()
    let topCurtain = UIView()
    let cropArea = UIView()
    let bottomCurtain = UIView()
    let toolbar = UIToolbar()

    convenience init(image: UIImage, ratio: Double) {
        self.init(frame: .zero)
        setupViewHierarchy()
        setupLayout(with: image, ratio: ratio)
        applyStyle()
        imageView.image = image
    }
    
    private func setupViewHierarchy() {
        [imageView, topCurtain, cropArea, bottomCurtain, toolbar].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
    
    private func setupLayout(with image: UIImage, ratio: Double) {
        let r: CGFloat = CGFloat(1.0 / ratio)
        NSLayoutConstraint.activate([
            topCurtain.topAnchor.constraint(equalTo: topAnchor),
            topCurtain.leadingAnchor.constraint(equalTo: leadingAnchor),
            topCurtain.trailingAnchor.constraint(equalTo: trailingAnchor),

            cropArea.topAnchor.constraint(equalTo: topCurtain.bottomAnchor),
            cropArea.leadingAnchor.constraint(equalTo: leadingAnchor),
            cropArea.trailingAnchor.constraint(equalTo: trailingAnchor),

            bottomCurtain.topAnchor.constraint(equalTo: cropArea.bottomAnchor),
            bottomCurtain.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomCurtain.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomCurtain.bottomAnchor.constraint(equalTo: bottomAnchor),

            toolbar.leadingAnchor.constraint(equalTo: leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

            cropArea.heightAnchor.constraint(equalTo: cropArea.widthAnchor, multiplier: r),
            cropArea.centerYAnchor.constraint(equalTo: centerYAnchor),


        ])
        //        layout(
        //            0,
        //            |topCurtain|,
        //            |cropArea|,
        //            |bottomCurtain|,
        //            0
        //        )
        //        |toolbar|
        //        if #available(iOS 11.0, *) {
        //            toolbar.Bottom == safeAreaLayoutGuide.Bottom
        //        } else {
        //            toolbar.bottom(0)
        //        }
        

        //        cropArea.Height == cropArea.Width * r
        //        cropArea.centerVertically()
        
        // Fit image differently depnding on its ratio.
        let imageRatio: Double = Double(image.size.width / image.size.height)
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
        //        // Fit imageView to image's bounds
        //        imageView.Width == imageView.Height * CGFloat(imageRatio)
    }
    
    private func applyStyle() {
        backgroundColor = .ypSystemBackground
        clipsToBounds = true

        imageView.isUserInteractionEnabled = true
        imageView.isMultipleTouchEnabled = true

        curtainStyle(v: topCurtain)
        cropArea.backgroundColor = .clear
        cropArea.isUserInteractionEnabled = false
        curtainStyle(v: bottomCurtain)

        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
    }
    
    func curtainStyle(v: UIView) {
        v.backgroundColor = UIColor.ypSystemBackground.withAlphaComponent(0.7)
        v.isUserInteractionEnabled = false
    }
}
