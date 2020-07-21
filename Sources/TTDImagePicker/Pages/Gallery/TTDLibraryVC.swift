import UIKit
import Photos

public class TTDLibraryVC: UIViewController, TTDPermissionCheckable {
    internal weak var delegate: TTDLibraryViewDelegate?
    internal var v: TTDLibraryView!
    internal var isProcessing = false // true if video or image is in processing state
    internal var multipleSelectionEnabled = false
    internal var initialized = false
    internal var selection = [TTDLibrarySelection]()
    internal var currentlySelectedIndex: Int = 0
    internal let mediaManager = LibraryMediaManager()
    internal var latestImageTapped = ""
    internal let panGestureHelper = PanGestureHelper()
    private let mediaType: TTDlibraryMediaType
    var isImagesGallery: Bool { mediaType == .photo }

    // MARK: - Init
    public required init(items: [TTDMediaItem]?, mediaType: TTDlibraryMediaType) {
        self.mediaType = mediaType
        super.init(nibName: nil, bundle: nil)
        title = TTDConfig.wordings.libraryTitle
        tabBarItem.selectedImage = imageFromBundle(isImagesGallery ? "imageGallerySelected" : "videoGallerySelected")
        tabBarItem.image = imageFromBundle(isImagesGallery ? "imageGalleryUnselected" : "videoGalleryUnselected")
    }
    
    public convenience init(mediaType: TTDlibraryMediaType) {
        self.init(items: nil, mediaType: mediaType)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAlbum(_ album: TTDAlbum) {
        title = album.title
        mediaManager.collection = album.collection
        currentlySelectedIndex = 0
        if !multipleSelectionEnabled {
            selection.removeAll()
        }
        refreshMediaRequest()
    }
    
    func initialize() {
        v.setEmptyState(hidden: true, animated: false)
        v.emptyView.set(title: isImagesGallery ? TTDConfig.wordings.emptyView.noImagesTitle : TTDConfig.wordings.emptyView.noVideosTitle,
                        message: isImagesGallery ? TTDConfig.wordings.emptyView.noImagesMessage : TTDConfig.wordings.emptyView.noVideosMessage,
                        buttonTitle: isImagesGallery ? TTDConfig.wordings.emptyView.noPhotosButtonTitle : TTDConfig.wordings.emptyView.noVideosButtonTitle,
                        icon: isImagesGallery ? imageFromBundle("imageGallerySelected") : imageFromBundle("videoGallerySelected"))

        v.emptyView.onTap = { [weak self] in
            guard let self = self else { return }
            self.isImagesGallery ? self.delegate?.didTapTakePicture() : self.delegate?.didTapUploadImage()
        }

        mediaManager.initialize()
        mediaManager.v = v

        if mediaManager.fetchResult != nil {
            return
        }
        
        setupCollectionView()
        registerForLibraryChanges()
        panGestureHelper.registerForPanGesture(on: v)
        registerForTapOnPreview()
        refreshMediaRequest()

        if TTDConfig.library.defaultMultipleSelection {
            multipleSelectionButtonTapped()
        }
        v.assetViewContainer.multipleSelectionButton.isHidden = true// !(TTDConfig.library.maxNumberOfItems > 1) //TODO: UNHIDE WHEN NEEDED
        v.maxNumberWarningLabel.text = String(format: TTDConfig.wordings.warningMaxItemsLimit, TTDConfig.library.maxNumberOfItems)
        
        if let preselectedItems = TTDConfig.library.preselectedItems {
            selection = preselectedItems.compactMap { item -> TTDLibrarySelection? in
                var itemAsset: PHAsset?
                switch item {
                case .photo(let photo):
                    itemAsset = photo.asset
                case .video(let video):
                    itemAsset = video.asset
                }
                guard let asset = itemAsset else {
                    return nil
                }
                
                // The negative index will be corrected in the collectionView:cellForItemAt:
                return TTDLibrarySelection(index: -1, assetIdentifier: asset.localIdentifier)
            }

            multipleSelectionEnabled = selection.count > 1
            v.assetViewContainer.setMultipleSelectionMode(on: multipleSelectionEnabled)
            v.collectionView.reloadData()
        }
    }
    
    // MARK: - View Lifecycle
    
    public override func loadView() {
        v = TTDLibraryView.xibView()
        view = v
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // When crop area changes in multiple selection mode,
        // we need to update the scrollView values in order to restore
        // them when user selects a previously selected item.
        v.assetZoomableView.cropAreaDidChange = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.updateCropInfo()
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        v.assetViewContainer.squareCropButton
            .addTarget(self,
                       action: #selector(squareCropButtonTapped),
                       for: .touchUpInside)
        v.assetViewContainer.multipleSelectionButton
            .addTarget(self,
                       action: #selector(multipleSelectionButtonTapped),
                       for: .touchUpInside)
        
        // Forces assetZoomableView to have a contentSize.
        // otherwise 0 in first selection triggering the bug : "invalid image size 0x0"
        // Also fits the first element to the square if the onlySquareFromLibrary = true
        if !TTDConfig.library.onlySquare && v.assetZoomableView.contentSize == CGSize(width: 0, height: 0) {
            v.assetZoomableView.setZoomScale(1, animated: false)
        }
        
        // Activate multiple selection when using `minNumberOfItems`
        if TTDConfig.library.minNumberOfItems > 1 {
            multipleSelectionButtonTapped()
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        pausePlayer()
        NotificationCenter.default.removeObserver(self)
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    // MARK: - Crop control
    
    @objc
    func squareCropButtonTapped() {
        doAfterPermissionCheck { [weak self] in
            self?.v.assetViewContainer.squareCropButtonTapped()
        }
    }
    
    // MARK: - Multiple Selection

    @objc
    func multipleSelectionButtonTapped() {
        doAfterPermissionCheck { [weak self] in
            self?.showMultipleSelection()
        }
    }
    
    private func showMultipleSelection() {
        if !multipleSelectionEnabled {
            selection.removeAll()
        }
        
        // Prevent desactivating multiple selection when using `minNumberOfItems`
        if TTDConfig.library.minNumberOfItems > 1 && multipleSelectionEnabled {
            return
        }
        
        multipleSelectionEnabled = !multipleSelectionEnabled

        if multipleSelectionEnabled {
            if selection.isEmpty {
                let asset = mediaManager.fetchResult[currentlySelectedIndex]
                selection = [
                    TTDLibrarySelection(index: currentlySelectedIndex,
                                       cropRect: v.currentCropRect(),
                                       scrollViewContentOffset: v.assetZoomableView!.contentOffset,
                                       scrollViewZoomScale: v.assetZoomableView!.zoomScale,
                                       assetIdentifier: asset.localIdentifier)
                ]
            }
        } else {
            selection.removeAll()
            addToSelection(indexPath: IndexPath(row: currentlySelectedIndex, section: 0))
        }

        v.assetViewContainer.setMultipleSelectionMode(on: multipleSelectionEnabled)
        v.collectionView.reloadData()
        checkLimit()
        delegate?.libraryViewDidToggleMultipleSelection(enabled: multipleSelectionEnabled)
    }
    
    // MARK: - Tap Preview
    
    func registerForTapOnPreview() {
        let tapImageGesture = UITapGestureRecognizer(target: self, action: #selector(tappedImage))
        v.assetViewContainer.addGestureRecognizer(tapImageGesture)
    }
    
    @objc
    func tappedImage() {
        if !panGestureHelper.isImageShown {
            panGestureHelper.resetToOriginalState()
            // no dragup? needed? dragDirection = .up
            v.refreshImageCurtainAlpha()
        }
    }
    
    // MARK: - Permissions
    
    func doAfterPermissionCheck(block: @escaping () -> Void) {
        checkPermissionToAccessPhotoLibrary { hasPermission in
            if hasPermission {
                block()
            }
        }
    }
    
    func checkPermission() {
        checkPermissionToAccessPhotoLibrary { [weak self] hasPermission in
            guard let strongSelf = self else {
                return
            }
            if hasPermission && !strongSelf.initialized {
                strongSelf.initialize()
                strongSelf.initialized = true
            }
        }
    }

    // Async beacause will prompt permission if .notDetermined
    // and ask custom popup if denied.
    func checkPermissionToAccessPhotoLibrary(block: @escaping (Bool) -> Void) {
        // Only intilialize picker if photo permission is Allowed by user.
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            block(true)
        case .restricted, .denied:
            let popup = TTDPermissionDeniedPopup()
            let alert = popup.popup(cancelBlock: {
                block(false)
            })
            present(alert, animated: true, completion: nil)
        case .notDetermined:
            // Show permission popup and get new status
            PHPhotoLibrary.requestAuthorization { s in
                DispatchQueue.main.async {
                    block(s == .authorized)
                }
            }
        @unknown default:
            fatalError()
        }
    }
    
    func refreshMediaRequest() {
        
        let options = buildPHFetchOptions()

        if let collection = mediaManager.collection {
            mediaManager.fetchResult = PHAsset.fetchAssets(in: collection, options: options)
        } else {
            mediaManager.fetchResult = PHAsset.fetchAssets(with: options)
        }
                
        if mediaManager.fetchResult.count > 0 {
            v.setEmptyState(hidden: true)
            changeAsset(mediaManager.fetchResult[0])
            v.collectionView.reloadData()
            v.collectionView.selectItem(at: IndexPath(row: 0, section: 0),
                                             animated: false,
                                             scrollPosition: UICollectionView.ScrollPosition())
            if !multipleSelectionEnabled {
                addToSelection(indexPath: IndexPath(row: 0, section: 0))
            }
        } else {
            delegate?.noPhotosForOptions()
            v.setEmptyState(hidden: false)
        }
        scrollToTop()
        v.collectionView.reloadData()
    }
    
    func buildPHFetchOptions() -> PHFetchOptions {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = mediaType.predicate()
        return options
    }
    
    func scrollToTop() {
        tappedImage()
        v.collectionView.contentOffset = CGPoint.zero
    }
    
    // MARK: - ScrollViewDelegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == v.collectionView {
            mediaManager.updateCachedAssets(in: self.v.collectionView)
        }
    }
    
    func changeAsset(_ asset: PHAsset) {
        latestImageTapped = asset.localIdentifier
        delegate?.libraryViewStartedLoadingImage()
        
        let completion = { (isLowResIntermediaryImage: Bool) in
            self.v.hideGrid()
            self.v.assetViewContainer.refreshSquareCropButton()
            self.updateCropInfo()
            if !isLowResIntermediaryImage {
                self.v.hideLoader()
                self.delegate?.libraryViewFinishedLoading()
            }
        }
        
        let updateCropInfo = {
            self.updateCropInfo()
        }
        //MARK: add a func(updateCropInfo) after crop multiple
        DispatchQueue.global(qos: .userInitiated).async {
            switch asset.mediaType {
            case .image:
                self.v.assetZoomableView.setImage(asset,
                                                  mediaManager: self.mediaManager,
                                                  storedCropPosition: self.fetchStoredCrop(),
                                                  completion: completion,
                                                  updateCropInfo: updateCropInfo)
            case .video:
                self.v.assetZoomableView.setVideo(asset,
                                                  mediaManager: self.mediaManager,
                                                  storedCropPosition: self.fetchStoredCrop(),
                                                  completion: { completion(false) },
                                                  updateCropInfo: updateCropInfo)
            case .audio, .unknown:
                ()
            @unknown default:
                fatalError()
            }
        }
    }
    
    // MARK: - Verification
    private func fitsVideoLengthLimits(asset: PHAsset) -> Bool {
        guard asset.mediaType == .video else {
            return true
        }
        
        let tooLong = floor(asset.duration) > TTDConfig.video.libraryTimeLimit
        let tooShort = floor(asset.duration) < TTDConfig.video.minimumTimeLimit
        
        if tooLong || tooShort {
            DispatchQueue.main.async {
                let alert = tooLong ? TTDAlert.videoTooLongAlert(self.view) : TTDAlert.videoTooShortAlert(self.view)
                self.present(alert, animated: true, completion: nil)
            }
            return false
        }
        
        return true
    }
    
    // MARK: - Stored Crop Position
    
    internal func updateCropInfo(shouldUpdateOnlyIfNil: Bool = false) {
        guard let selectedAssetIndex = selection.firstIndex(where: { $0.index == currentlySelectedIndex }) else {
            return
        }
        
        if shouldUpdateOnlyIfNil && selection[selectedAssetIndex].scrollViewContentOffset != nil {
            return
        }
        
        // Fill new values
        var selectedAsset = selection[selectedAssetIndex]
        selectedAsset.scrollViewContentOffset = v.assetZoomableView.contentOffset
        selectedAsset.scrollViewZoomScale = v.assetZoomableView.zoomScale
        selectedAsset.cropRect = v.currentCropRect()
        
        // Replace
        selection.remove(at: selectedAssetIndex)
        selection.insert(selectedAsset, at: selectedAssetIndex)
    }
    
    internal func fetchStoredCrop() -> TTDLibrarySelection? {
        if self.multipleSelectionEnabled,
            self.selection.contains(where: { $0.index == self.currentlySelectedIndex }) {
            guard let selectedAssetIndex = self.selection
                .firstIndex(where: { $0.index == self.currentlySelectedIndex }) else {
                return nil
            }
            return self.selection[selectedAssetIndex]
        }
        return nil
    }
    
    internal func hasStoredCrop(index: Int) -> Bool {
        return self.selection.contains(where: { $0.index == index })
    }
    
    // MARK: - Fetching Media
    
    private func fetchImageAndCrop(for asset: PHAsset,
                                   withCropRect: CGRect? = nil,
                                   callback: @escaping (_ photo: UIImage, _ exif: [String : Any]) -> Void) {
        delegate?.libraryViewDidTapNext()
        let cropRect = withCropRect ?? DispatchQueue.main.sync { v.currentCropRect() }
        let ts = targetSize(for: asset, cropRect: cropRect)
        mediaManager.imageManager?.fetchImage(for: asset, cropRect: cropRect, targetSize: ts, callback: callback)
    }
    
    private func checkVideoLengthAndCrop(for asset: PHAsset,
                                         withCropRect: CGRect? = nil,
                                         callback: @escaping (_ videoURL: URL?) -> Void) {
        if fitsVideoLengthLimits(asset: asset) == true {
            delegate?.libraryViewDidTapNext()
            let normalizedCropRect = withCropRect ?? DispatchQueue.main.sync { v.currentCropRect() }
            let ts = targetSize(for: asset, cropRect: normalizedCropRect)
            let xCrop: CGFloat = normalizedCropRect.origin.x * CGFloat(asset.pixelWidth)
            let yCrop: CGFloat = normalizedCropRect.origin.y * CGFloat(asset.pixelHeight)
            let resultCropRect = CGRect(x: xCrop,
                                        y: yCrop,
                                        width: ts.width,
                                        height: ts.height)
            mediaManager.fetchVideoUrlAndCrop(for: asset, cropRect: resultCropRect, callback: callback)
        }
    }
    
    public func selectedMedia(photoCallback: @escaping (_ photo: TTDMediaPhoto) -> Void,
                              videoCallback: @escaping (_ videoURL: TTDMediaVideo) -> Void,
                              multipleItemsCallback: @escaping (_ items: [TTDMediaItem]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            
            let selectedAssets: [(asset: PHAsset, cropRect: CGRect?)] = self.selection.map {
                guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [$0.assetIdentifier], options: PHFetchOptions()).firstObject else { fatalError() }
                return (asset, $0.cropRect)
            }
            
            // Multiple selection
            if self.multipleSelectionEnabled && self.selection.count > 1 {
                
                // Check video length
                for asset in selectedAssets {
                    if self.fitsVideoLengthLimits(asset: asset.asset) == false {
                        return
                    }
                }
                
                // Fill result media items array
                var resultMediaItems: [TTDMediaItem] = []
                let asyncGroup = DispatchGroup()
                
                for asset in selectedAssets {
                    asyncGroup.enter()
                    
                    switch asset.asset.mediaType {
                    case .image:
                        self.fetchImageAndCrop(for: asset.asset, withCropRect: asset.cropRect) { image, exifMeta in
                            let photo = TTDMediaPhoto(image: image.resizedImageIfNeeded(), exifMeta: exifMeta, asset: asset.asset)
                            resultMediaItems.append(TTDMediaItem.photo(p: photo))
                            asyncGroup.leave()
                        }
                        
                    case .video:
                        self.checkVideoLengthAndCrop(for: asset.asset, withCropRect: asset.cropRect) { videoURL in
                            if let videoURL = videoURL {
                                let videoItem = TTDMediaVideo(thumbnail: thumbnailFromVideoPath(videoURL),
                                                             videoURL: videoURL, asset: asset.asset)
                                resultMediaItems.append(TTDMediaItem.video(v: videoItem))
                            } else {
                                print("TTDLibraryVC -> selectedMedia -> Problems with fetching videoURL.")
                            }
                            asyncGroup.leave()
                        }
                    default:
                        break
                    }
                }
                
                asyncGroup.notify(queue: .main) {
                    multipleItemsCallback(resultMediaItems)
                    self.delegate?.libraryViewFinishedLoading()
                }
            } else {
                let asset = selectedAssets.first!.asset
                switch asset.mediaType {
                case .audio, .unknown:
                    return
                case .video:
                    self.checkVideoLengthAndCrop(for: asset, callback: { videoURL in
                        DispatchQueue.main.async {
                            if let videoURL = videoURL {
                                self.delegate?.libraryViewFinishedLoading()
                                let video = TTDMediaVideo(thumbnail: thumbnailFromVideoPath(videoURL),
                                                         videoURL: videoURL, asset: asset)
                                videoCallback(video)
                            } else {
                                print("TTDLibraryVC -> selectedMedia -> Problems with fetching videoURL.")
                            }
                        }
                    })
                case .image:
                    self.fetchImageAndCrop(for: asset) { image, exifMeta in
                        DispatchQueue.main.async {
                            self.delegate?.libraryViewFinishedLoading()
                            let photo = TTDMediaPhoto(image: image.resizedImageIfNeeded(),
                                                     exifMeta: exifMeta,
                                                     asset: asset)
                            photoCallback(photo)
                        }
                    }
                @unknown default:
                    fatalError()
                }
                return
            }
        }
    }
    
    // MARK: - TargetSize
    
    private func targetSize(for asset: PHAsset, cropRect: CGRect) -> CGSize {
        var width = (CGFloat(asset.pixelWidth) * cropRect.width).rounded(.toNearestOrEven)
        var height = (CGFloat(asset.pixelHeight) * cropRect.height).rounded(.toNearestOrEven)
        // round to lowest even number
        width = (width.truncatingRemainder(dividingBy: 2) == 0) ? width : width - 1
        height = (height.truncatingRemainder(dividingBy: 2) == 0) ? height : height - 1
        return CGSize(width: width, height: height)
    }
    
    // MARK: - Player
    
    func pausePlayer() {
        v.assetZoomableView.videoView.pause()
    }
    
    // MARK: - Deinit
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}
