//
//  YPFiltersView.swift
//  photoTaking
//
//  Created by Sacha Durand Saint Omer on 21/10/16.
//  Copyright © 2016 octopepper. All rights reserved.
//

import UIKit

class YPFiltersView: UIView {
    
    let imageView = UIImageView()
    var collectionView: UICollectionView!
    var filtersLoader: UIActivityIndicatorView!
    fileprivate let collectionViewContainer: UIView = UIView()
    
    convenience init() {
        self.init(frame: CGRect.zero)
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout())
        filtersLoader = UIActivityIndicatorView(style: .gray)
        filtersLoader.hidesWhenStopped = true
        filtersLoader.startAnimating()
        filtersLoader.color = YPConfig.colors.tintColor

        [imageView, collectionViewContainer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        [filtersLoader, collectionView].compactMap{$0}.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            collectionViewContainer.addSubview($0)
        }

        let isIphone4 = UIScreen.main.bounds.height == 480
        let sideMargin: CGFloat = isIphone4 ? 20 : 0

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: sideMargin),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -sideMargin),
            imageView.bottomAnchor.constraint(equalTo: collectionViewContainer.topAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1),

            collectionViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionViewContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: sideMargin),
            collectionViewContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -sideMargin),


            collectionView.centerYAnchor.constraint(equalTo: collectionViewContainer.centerYAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 160),
            collectionView.leadingAnchor.constraint(equalTo: collectionViewContainer.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: collectionViewContainer.trailingAnchor),

            filtersLoader.centerYAnchor.constraint(equalTo: collectionViewContainer.centerYAnchor),
            filtersLoader.centerXAnchor.constraint(equalTo: collectionViewContainer.centerXAnchor)
        ])
        
        backgroundColor = .offWhiteOrBlack
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    func layout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        layout.itemSize = CGSize(width: 100, height: 120)
        return layout
    }
}
