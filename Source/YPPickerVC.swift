//
//  YYPPickerVC.swift
//  YPPickerVC
//
//  Created by Sacha Durand Saint Omer on 25/10/16.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import Foundation
import UIKit
import Photos

protocol ImagePickerDelegate: AnyObject {
    func noPhotos()
}

open class YPPickerVC: YPBottomPager, YPBottomPagerDelegate {

    private var currentLibraryVC: YPLibraryVC? {
        mode == .photoLibraryMode ? photoLibraryVC : videoLibraryVC
    }

    let albumsManager = YPAlbumsManager()
    var shouldHideStatusBar = false
    var initialStatusBarHidden = false
    weak var imagePickerDelegate: ImagePickerDelegate?
    
    override open var prefersStatusBarHidden: Bool {
        return (shouldHideStatusBar || initialStatusBarHidden) && YPConfig.hidesStatusBar
    }
    
    /// Private callbacks to YPImagePicker
    public var didClose:(() -> Void)?
    public var didSelectItems: (([YPMediaItem]) -> Void)?
    
    enum Mode {
        case photoLibraryMode
        case videoLibraryMode
        case cameraMode
    }
    
    private var photoLibraryVC: YPLibraryVC?
    private var videoLibraryVC: YPLibraryVC?
    private var cameraVC: YPCameraVC?
    
    var mode = Mode.cameraMode
    
    var capturedImage: UIImage?
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = YPConfig.colors.safeAreaBackgroundColor
        
        delegate = self
        
        // Force Library only when using `minNumberOfItems`.
        if YPConfig.library.minNumberOfItems > 1 {
            YPImagePickerConfiguration.shared.screens = [.photoLibrary]
        }
        
        // Library
        if YPConfig.screens.contains(.photoLibrary) {
            photoLibraryVC = YPLibraryVC(mediaType: .photo)
            photoLibraryVC?.delegate = self
        }

        if YPConfig.screens.contains(.videoLibrary) {
            videoLibraryVC = YPLibraryVC(mediaType: .video)
            videoLibraryVC?.delegate = self
        }
        
        // Camera
        if YPConfig.screens.contains(.photo) {
            cameraVC = YPCameraVC()
            cameraVC?.didCapturePhoto = { [weak self] img in
                self?.didSelectItems?([YPMediaItem.photo(p: YPMediaPhoto(image: img,
                                                                        fromCamera: true))])
            }
        }
        
        // Show screens
        var vcs = [UIViewController]()
        for screen in YPConfig.screens {
            switch screen {
            case .videoLibrary:
                guard let videoLibraryVC = videoLibraryVC else { continue }
                vcs.append(videoLibraryVC)
            case .photoLibrary:
                guard let photoLibraryVC = photoLibraryVC  else { continue }
                vcs.append(photoLibraryVC)
            case .photo:
                guard  let cameraVC = cameraVC else  { continue }
                vcs.append(cameraVC)
            }
        }
        controllers = vcs
        
        // Select good mode
        if YPConfig.screens.contains(YPConfig.startOnScreen) {
            switch YPConfig.startOnScreen {
            case .videoLibrary:
                mode = .videoLibraryMode
            case .photoLibrary:
                mode = .photoLibraryMode
            case .photo:
                mode = .cameraMode
            }
        }
        
        // Select good screen
        if let index = YPConfig.screens.firstIndex(of: YPConfig.startOnScreen) {
            startOnPage(index)
        }
        
        YPHelper.changeBackButtonIcon(self)
        YPHelper.changeBackButtonTitle(self)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraVC?.v.shotButton.isEnabled = true
        
        updateMode(with: currentController)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shouldHideStatusBar = true
        initialStatusBarHidden = true
        UIView.animate(withDuration: 0.3) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    internal func pagerScrollViewDidScroll(_ scrollView: UIScrollView) { }
    
    func modeFor(vc: UIViewController) -> Mode {
        switch vc {
        case photoLibraryVC:
             return .photoLibraryMode
        case videoLibraryVC:
            return .videoLibraryMode
        case cameraVC:
            return .cameraMode
        default:
            return .cameraMode
        }
    }
    
    func pagerDidSelectController(_ vc: UIViewController) {
        updateMode(with: vc)
    }
    
    func updateMode(with vc: UIViewController) {
        stopCurrentCamera()
        
        // Set new mode
        mode = modeFor(vc: vc)
        
        // Re-trigger permission check
        if let vc = vc as? YPLibraryVC {
            vc.checkPermission()
        } else if let cameraVC = vc as? YPCameraVC {
            cameraVC.start()
        }
        updateUI()
    }
    
    func stopCurrentCamera() {
        switch mode {
        case .videoLibraryMode, .photoLibraryMode:
            currentLibraryVC?.pausePlayer()
        case .cameraMode:
            cameraVC?.stopCamera()
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        shouldHideStatusBar = false
        stopAll()
    }
    
    @objc
    func navBarTapped() {
        let vc = YPAlbumVC(albumsManager: albumsManager)
        let navVC = UINavigationController(rootViewController: vc)
        navVC.navigationBar.tintColor = .ypLabel
        
        vc.didSelectAlbum = { [weak self] album in
            self?.currentLibraryVC?.setAlbum(album)
            self?.setTitleViewWithTitle(aTitle: album.title)
            navVC.dismiss(animated: true, completion: nil)
        }
        present(navVC, animated: true, completion: nil)
    }
    
    func setTitleViewWithTitle(aTitle: String) {
        let titleView = UIStackView()
        titleView.alignment = .center
        titleView.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        titleView.spacing = 8

        let label = UILabel()
        label.text = aTitle
        // Use standard font by default.
        label.font = UIFont.boldSystemFont(ofSize: 17)
        
        // Use custom font if set by user.
        if let navBarTitleFont = UINavigationBar.appearance().titleTextAttributes?[.font] as? UIFont {
            // Use custom font if set by user.
            label.font = navBarTitleFont
        }
        // Use custom textColor if set by user.
        if let navBarTitleColor = UINavigationBar.appearance().titleTextAttributes?[.foregroundColor] as? UIColor {
            label.textColor = navBarTitleColor
        }
        
        if YPConfig.library.options != nil {
            titleView.addArrangedSubview(label)
        } else {
            let arrow = UIImageView()
            arrow.image = YPConfig.icons.arrowDownIcon
            arrow.image = arrow.image?.withRenderingMode(.alwaysTemplate)
            arrow.tintColor = .ypLabel
            
            let attributes = UINavigationBar.appearance().titleTextAttributes
            if let attributes = attributes, let foregroundColor = attributes[.foregroundColor] as? UIColor {
                arrow.image = arrow.image?.withRenderingMode(.alwaysTemplate)
                arrow.tintColor = foregroundColor
            }
            
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(navBarTapped), for: .touchUpInside)
            button.setBackgroundColor(UIColor.white.withAlphaComponent(0.5), forState: .highlighted)

            titleView.addArrangedSubview(label)
            titleView.addArrangedSubview(arrow)
            titleView.addSubview(button)

            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalTo: titleView.heightAnchor),
                button.widthAnchor.constraint(equalTo: titleView.widthAnchor),
                button.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
                button.centerXAnchor.constraint(equalTo: titleView.centerXAnchor)
            ])
        }
        
        label.firstBaselineAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -14).isActive = true
        titleView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        navigationItem.titleView = titleView
    }
    
    func updateUI() {
        // Update Nav Bar state.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: YPConfig.wordings.cancel,
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(close))
        switch mode { //TODO: refactor this
        case .videoLibraryMode, .photoLibraryMode:
            setTitleViewWithTitle(aTitle: currentLibraryVC?.title ?? "")
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: YPConfig.wordings.next,
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(done))
            navigationItem.rightBarButtonItem?.tintColor = YPConfig.colors.tintColor
            // Disable Next Button until minNumberOfItems is reached.
            navigationItem.rightBarButtonItem?.isEnabled = currentLibraryVC!.selection.count >= YPConfig.library.minNumberOfItems
        case .cameraMode:
            navigationItem.titleView = nil
            title = cameraVC?.title
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc
    func close() {
        // Cancelling exporting of all videos
        if let libraryVC = currentLibraryVC {
            libraryVC.mediaManager.forseCancelExporting()
        }
        self.didClose?()
    }
    
    // When pressing "Next"
    @objc
    func done() {
        guard let currentLibraryVC = currentLibraryVC else { print("⚠️ YPPickerVC >>> YPLibraryVC deallocated"); return }
        if mode == .photoLibraryMode || mode == .videoLibraryMode {
            currentLibraryVC.doAfterPermissionCheck { [weak self] in
                currentLibraryVC.selectedMedia(photoCallback: { photo in
                    self?.didSelectItems?([YPMediaItem.photo(p: photo)])
                }, videoCallback: { video in
                    self?.didSelectItems?([YPMediaItem
                        .video(v: video)])
                }, multipleItemsCallback: { items in
                    self?.didSelectItems?(items)
                })
            }
        }
    }
    
    func stopAll() {
        photoLibraryVC?.v.assetZoomableView.videoView.deallocate()
        videoLibraryVC?.v.assetZoomableView.videoView.deallocate()
        cameraVC?.stopCamera()
    }
}

extension YPPickerVC: YPLibraryViewDelegate {
    
    public func libraryViewDidTapNext() {
        photoLibraryVC?.isProcessing = true
        DispatchQueue.main.async {
            self.v.scrollView.isScrollEnabled = false
            self.photoLibraryVC?.v.fadeInLoader()
            self.navigationItem.rightBarButtonItem = YPLoaders.defaultLoader
        }
    }
    
    public func libraryViewStartedLoadingImage() {
        photoLibraryVC?.isProcessing = true //TODO remove to enable changing selection while loading but needs cancelling previous image requests.
        DispatchQueue.main.async {
            self.photoLibraryVC?.v.fadeInLoader()
        }
    }
    
    public func libraryViewFinishedLoading() {
        photoLibraryVC?.isProcessing = false
        DispatchQueue.main.async {
            self.v.scrollView.isScrollEnabled = YPConfig.isScrollToChangeModesEnabled
            self.photoLibraryVC?.v.hideLoader()
            self.updateUI()
        }
    }
    
    public func libraryViewDidToggleMultipleSelection(enabled: Bool) {
        var offset = v.header.frame.height
        offset += v.safeAreaInsets.bottom
        v.headerBottomConstraint.constant = enabled ? offset : 0
        v.layoutIfNeeded()
        updateUI()
    }
    
    public func noPhotosForOptions() { //TODO: - clarify what to do
        self.imagePickerDelegate?.noPhotos()
    }
}
