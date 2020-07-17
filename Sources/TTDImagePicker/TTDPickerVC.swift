import Foundation
import UIKit
import Photos

protocol ImagePickerDelegate: AnyObject {
    func noPhotos()
}

open class TTDPickerVC: TTDBottomPager, TTDBottomPagerDelegate {

    private var currentLibraryVC: TTDLibraryVC? {
        mode == .photoLibraryMode ? photoLibraryVC : videoLibraryVC
    }

    let albumsManager = TTDAlbumsManager()
    var shouldHideStatusBar = false
    var initialStatusBarHidden = false
    weak var imagePickerDelegate: ImagePickerDelegate?
    
    override open var prefersStatusBarHidden: Bool {
        return (shouldHideStatusBar || initialStatusBarHidden) && TTDConfig.hidesStatusBar
    }
    
    /// Private callbacks to TTDImagePicker
    public var didClose:(() -> Void)?
    public var didSelectItems: (([TTDMediaItem]) -> Void)?
    
    enum Mode {
        case photoLibraryMode
        case videoLibraryMode
        case cameraMode
    }
    
    private var photoLibraryVC: TTDLibraryVC?
    private var videoLibraryVC: TTDLibraryVC?
    private var cameraVC: TTDCameraVC?
    
    var mode = Mode.cameraMode
    
    var capturedImage: UIImage?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TTDConfig.colors.safeAreaBackgroundColor
        delegate = self
        
        // Force Library only when using `minNumberOfItems`.
        if TTDConfig.library.minNumberOfItems > 1 {
            TTDImagePickerConfiguration.shared.screens = [.photoLibrary]
        }
        
        // Library
        if TTDConfig.screens.contains(.photoLibrary) {
            photoLibraryVC = TTDLibraryVC(mediaType: .photo)
            photoLibraryVC?.delegate = self
        }

        if TTDConfig.screens.contains(.videoLibrary) {
            videoLibraryVC = TTDLibraryVC(mediaType: .video)
            videoLibraryVC?.delegate = self
        }
        
        // Camera
        if TTDConfig.screens.contains(.photo) {
            cameraVC = TTDCameraVC()
            cameraVC?.didCapturePhoto = { [weak self] img in
                self?.didSelectItems?([TTDMediaItem.photo(p: TTDMediaPhoto(image: img,
                                                                        fromCamera: true))])
            }
        }
        
        // Show screens
        var vcs = [UIViewController]()
        for screen in TTDConfig.screens {
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
        if TTDConfig.screens.contains(TTDConfig.startOnScreen) {
            switch TTDConfig.startOnScreen {
            case .videoLibrary:
                mode = .videoLibraryMode
            case .photoLibrary:
                mode = .photoLibraryMode
            case .photo:
                mode = .cameraMode
            }
        }
        
        // Select good screen
        if let index = TTDConfig.screens.firstIndex(of: TTDConfig.startOnScreen) {
            startOnPage(index)
        }
        
        TTDHelper.changeBackButtonIcon(self)
        TTDHelper.changeBackButtonTitle(self)
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
        if let vc = vc as? TTDLibraryVC {
            vc.checkPermission()
        } else if let cameraVC = vc as? TTDCameraVC {
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
        let vc = TTDAlbumVC(albumsManager: albumsManager)
        let navVC = UINavigationController(rootViewController: vc)
        navVC.navigationBar.tintColor = .labelColor
        
        vc.didSelectAlbum = { [weak self] album in
            self?.currentLibraryVC?.setAlbum(album)
            self?.setTitleViewWithTitle(aTitle: album.title)
            navVC.dismiss(animated: true, completion: nil)
        }
        present(navVC, animated: true, completion: nil)
    }
    
    func setTitleViewWithTitle(aTitle: String, includeAlbumButton: Bool = true) {
        let titleView = UIStackView()
        titleView.alignment = .center
        titleView.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        titleView.spacing = 8

        let label = UILabel()
        label.text = aTitle
        // Use standard font by default.
        label.font = UIFont.boldSystemFont(ofSize: 17)
        
        if TTDConfig.library.options != nil || !includeAlbumButton {
            titleView.addArrangedSubview(label)
        } else {
            let arrow = UIImageView()
            arrow.image = TTDConfig.icons.arrowDownIcon
            arrow.image = arrow.image?.withRenderingMode(.alwaysTemplate)
            arrow.tintColor = .labelColor
            
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: TTDConfig.wordings.cancel,
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(close))
        navigationItem.leftBarButtonItem?.tintColor = TTDConfig.colors.secondaryTintColor
        switch mode { //TODO: refactor this
        case .photoLibraryMode, .videoLibraryMode:
            let isVideoMode = mode == .videoLibraryMode
            isVideoMode ? setTitleViewWithTitle(aTitle: "Videos", includeAlbumButton: false) : setTitleViewWithTitle(aTitle: currentLibraryVC?.title ?? "")
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: TTDConfig.wordings.next,
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(done))
            navigationItem.rightBarButtonItem?.tintColor = TTDConfig.colors.tintColor
            // Disable Next Button until minNumberOfItems is reached.
            navigationItem.rightBarButtonItem?.isEnabled = currentLibraryVC!.selection.count >= TTDConfig.library.minNumberOfItems
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
        guard let currentLibraryVC = currentLibraryVC else { print("⚠️ TTDPickerVC >>> TTDLibraryVC deallocated"); return }
        if mode == .photoLibraryMode || mode == .videoLibraryMode {
            currentLibraryVC.doAfterPermissionCheck { [weak self] in
                currentLibraryVC.selectedMedia(photoCallback: { photo in
                    self?.didSelectItems?([TTDMediaItem.photo(p: photo)])
                }, videoCallback: { video in
                    self?.didSelectItems?([TTDMediaItem
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

extension TTDPickerVC: TTDLibraryViewDelegate {
    
    public func libraryViewDidTapNext() {
        photoLibraryVC?.isProcessing = true
        DispatchQueue.main.async {
            self.v.scrollView.isScrollEnabled = false
            self.photoLibraryVC?.v.fadeInLoader()
            self.navigationItem.rightBarButtonItem = TTDLoaders.defaultLoader
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
            self.v.scrollView.isScrollEnabled = TTDConfig.isScrollToChangeModesEnabled
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
    
    public func noPhotosForOptions() {
        self.imagePickerDelegate?.noPhotos()
    }
}
