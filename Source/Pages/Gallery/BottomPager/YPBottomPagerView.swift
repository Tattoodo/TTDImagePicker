//
//  YPBottomPagerView.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 24/01/2018.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import UIKit

final class YPBottomPagerView: UIView {
    
    var header = YPPagerMenu()
    var scrollView = UIScrollView()
    
    convenience init() {
        self.init(frame: .zero)
        backgroundColor = .red
        [scrollView, header].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),

            header.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
            header.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            header.heightAnchor.constraint(equalToConstant: (YPConfig.hidesBottomBar || (YPConfig.screens.count == 1)) ? 0 : 44),
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            header.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
        ])
        clipsToBounds = false
        setupScrollView()
    }

    private func setupScrollView() {
        scrollView.clipsToBounds = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.bounces = false
    }
}
