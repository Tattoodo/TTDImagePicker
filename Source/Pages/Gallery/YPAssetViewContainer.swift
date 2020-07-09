//
//  YPAssetViewContainer.swift
//  YPImagePicker
//
//  Created by Sacha Durand Saint Omer on 15/11/2016.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

/// The container for asset (video or image). It containts the YPGridView and YPAssetZoomableView.
class YPAssetViewContainer: UIView {
    public var zoomableView: YPAssetZoomableView?
    public let grid = YPGridView()
    public let curtain = UIView()

    private lazy var spinner = UIActivityIndicatorView(style: .white)
    public lazy var spinnerView: UIView = {
        let view = UIView()
        view.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()

    public let squareCropButton = UIButton()
    public let multipleSelectionButton = UIButton()
    public var onlySquare = YPConfig.library.onlySquare
    public var isShown = true
    

    private var shouldCropToSquare = YPConfig.library.isSquareByDefault
    private var isMultipleSelection = false

    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(grid)
        grid.frame = frame
        clipsToBounds = true

        subviews.compactMap { $0 as? YPAssetZoomableView }.forEach {
            zoomableView = $0
            zoomableView?.myDelegate = self
        }
        grid.alpha = 0
        
        let touchDownGR = UILongPressGestureRecognizer(target: self,
                                                       action: #selector(handleTouchDown))
        touchDownGR.minimumPressDuration = 0
        touchDownGR.delegate = self
        addGestureRecognizer(touchDownGR)

        [spinnerView, curtain].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
            NSLayoutConstraint.activate([
                $0.topAnchor.constraint(equalTo: topAnchor),
                $0.bottomAnchor.constraint(equalTo: bottomAnchor),
                $0.leadingAnchor.constraint(equalTo: leadingAnchor),
                $0.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        }
        
        spinner.startAnimating()
        spinnerView.backgroundColor = UIColor.ypLabel.withAlphaComponent(0.3)
        curtain.backgroundColor = UIColor.ypLabel.withAlphaComponent(0.7)
        curtain.alpha = 0
        
        if !onlySquare {
            squareCropButton.setImage(YPConfig.icons.cropIcon, for: .normal)
            squareCropButton.translatesAutoresizingMaskIntoConstraints = false
            addSubview(squareCropButton)
            NSLayoutConstraint.activate([
                squareCropButton.heightAnchor.constraint(equalToConstant: 42),
                squareCropButton.widthAnchor.constraint(equalToConstant: 42),
                squareCropButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                squareCropButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
            ])
        }
        
        // Multiple selection button
        multipleSelectionButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(multipleSelectionButton)
        NSLayoutConstraint.activate([
            multipleSelectionButton.heightAnchor.constraint(equalToConstant: 42),
            multipleSelectionButton.widthAnchor.constraint(equalToConstant: 42),
            multipleSelectionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            multipleSelectionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
        multipleSelectionButton.setImage(YPConfig.icons.multipleSelectionOffIcon, for: .normal)
    }
    
    // MARK: - Square button
    @objc public func squareCropButtonTapped() {
        if let zoomableView = zoomableView {
            let z = zoomableView.zoomScale
            shouldCropToSquare = (z >= 1 && z < zoomableView.squaredZoomScale)
        }
        zoomableView?.fitImage(shouldCropToSquare, animated: true)
    }
    
    
    public func refreshSquareCropButton() {
        if onlySquare {
            squareCropButton.isHidden = true
        } else {
            if let image = zoomableView?.assetImageView.image {
                let isImageASquare = image.size.width == image.size.height
                squareCropButton.isHidden = isImageASquare
            }
        }
        
        let shouldFit = YPConfig.library.onlySquare ? true : shouldCropToSquare
        zoomableView?.fitImage(shouldFit)
        zoomableView?.layoutSubviews()
    }
    
    // MARK: - Multiple selection

    /// Use this to update the multiple selection mode UI state for the YPAssetViewContainer
    public func setMultipleSelectionMode(on: Bool) {
        isMultipleSelection = on
        let image = on ? YPConfig.icons.multipleSelectionOnIcon : YPConfig.icons.multipleSelectionOffIcon
        multipleSelectionButton.setImage(image, for: .normal)
        refreshSquareCropButton()
    }
}

// MARK: - ZoomableViewDelegate
extension YPAssetViewContainer: YPAssetZoomableViewDelegate {
    public func ypAssetZoomableViewDidLayoutSubviews(_ zoomableView: YPAssetZoomableView) {
        let newFrame = zoomableView.assetImageView.convert(zoomableView.assetImageView.bounds, to: self)
        
        // update grid position
        grid.frame = frame.intersection(newFrame)
        grid.layoutIfNeeded()
        
        // Update play imageView position - bringing the playImageView from the videoView to assetViewContainer,
        // but the controll for appearing it still in videoView.
        if zoomableView.videoView.playImageView.isDescendant(of: self) == false {
            self.addSubview(zoomableView.videoView.playImageView)
            zoomableView.videoView.playImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            zoomableView.videoView.playImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
    }
    
    public func ypAssetZoomableViewScrollViewDidZoom() {
        if isShown {
            UIView.animate(withDuration: 0.1) {
                self.grid.alpha = 1
            }
        }
    }
    
    public func ypAssetZoomableViewScrollViewDidEndZooming() {
        UIView.animate(withDuration: 0.3) {
            self.grid.alpha = 0
        }
    }
}

// MARK: - Gesture recognizer Delegate
extension YPAssetViewContainer: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith
        otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIButton)
    }
    
    @objc
    private func handleTouchDown(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            if isShown {
                UIView.animate(withDuration: 0.1) {
                    self.grid.alpha = 1
                }
            }
        case .ended:
            UIView.animate(withDuration: 0.3) {
                self.grid.alpha = 0
            }
        default: ()
        }
    }
}
