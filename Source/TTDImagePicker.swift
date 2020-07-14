import UIKit
import AVFoundation
import Photos

public protocol TTDImagePickerDelegate: AnyObject {
    func noPhotos()
}

open class TTDImagePicker: UINavigationController {
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    private var _didFinishPicking: (([TTDMediaItem], Bool) -> Void)?

    public func didFinishPicking(completion: @escaping (_ items: [TTDMediaItem], _ cancelled: Bool) -> Void) {
        _didFinishPicking = completion
    }
    public weak var imagePickerDelegate: TTDImagePickerDelegate?
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return TTDImagePickerConfiguration.shared.preferredStatusBarStyle
    }
    
    // This nifty little trick enables us to call the single version of the callbacks.
    // This keeps the backwards compatibility keeps the api as simple as possible.
    // Multiple selection becomes available as an opt-in.
    private func didSelect(items: [TTDMediaItem]) {
        _didFinishPicking?(items, false)
    }
    
    let loadingView = TTDLoadingView()
    private let picker: TTDPickerVC!
    
    /// Get a TTDImagePicker instance with the default configuration.
    public convenience init() {
        self.init(configuration: TTDImagePickerConfiguration.shared)
    }
    
    /// Get a TTDImagePicker with the specified configuration.
    public required init(configuration: TTDImagePickerConfiguration) {
        TTDImagePickerConfiguration.shared = configuration
        picker = TTDPickerVC()
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen // Force .fullScreen as iOS 13 now shows modals as cards by default.
        picker.imagePickerDelegate = self
        navigationBar.tintColor = .ypLabel
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
override open func viewDidLoad() {
        super.viewDidLoad()
        picker.didClose = { [weak self] in
            self?._didFinishPicking?([], true)
        }
        viewControllers = [picker]
        setupLoadingView()
        navigationBar.isTranslucent = false

        picker.didSelectItems = { [weak self] items in
            // Use Fade transition instead of default push animation
            let transition = CATransition()
            transition.duration = 0.3
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.type = CATransitionType.fade
            self?.view.layer.add(transition, forKey: nil)
            
            // Multiple items flow
            if items.count > 1 {
                if TTDConfig.library.skipSelectionsGallery {
                    self?.didSelect(items: items)
                    return
                } else {
                    let selectionsGalleryVC = TTDSelectionsGalleryVC(items: items) { _, items in
                        self?.didSelect(items: items)
                    }
                    self?.pushViewController(selectionsGalleryVC, animated: true)
                    return
                }
            }
            
            // One item flow
            let item = items.first!
            switch item {
            case .photo(let photo):
                let completion = { (photo: TTDMediaPhoto) in
                    let mediaItem = TTDMediaItem.photo(p: photo)
                    // Save new image or existing but modified, to the photo album.
                    if TTDConfig.shouldSaveNewPicturesToAlbum {
                        let isModified = photo.modifiedImage != nil
                        if photo.fromCamera || (!photo.fromCamera && isModified) {
                            TTDPhotoSaver.trySaveImage(photo.image, inAlbumNamed: TTDConfig.albumName)
                        }
                    }
                    self?.didSelect(items: [mediaItem])
                }
                
                func showCropVC(photo: TTDMediaPhoto, completion: @escaping (_ aphoto: TTDMediaPhoto) -> Void) {
                    if TTDConfig.showsCrop {
                        let vc = cropViewController(image: photo.image)
                        vc.didFinishCropping = { result in
                            switch result {
                            case .success(let croppedImage):
                                photo.modifiedImage = croppedImage
                                completion(photo)
                            case .failure(let error):
                                print(error)
                                self?.popViewController(animated: true)
                            }
                        }
                        self?.pushViewController(vc, animated: true)
                    } else {
                        completion(photo)
                    }
                }

                if TTDConfig.showsPhotoFilters {
                    let filterVC = TTDPhotoFiltersVC(inputPhoto: photo,
                                                    isFromSelectionVC: false)
                    // Show filters and then crop
                    filterVC.didSave = { outputMedia in
                        if case let TTDMediaItem.photo(outputPhoto) = outputMedia {
                            showCropVC(photo: outputPhoto, completion: completion)
                        }
                    }
                    self?.pushViewController(filterVC, animated: false)
                } else {
                    showCropVC(photo: photo, completion: completion)
                }
            case .video(let video):
                if TTDConfig.showsVideoTrimmer {
                    let videoFiltersVC = TTDVideoFiltersVC.initWith(video: video,
                                                                   isFromSelectionVC: false)
                    videoFiltersVC.didSave = { [weak self] outputMedia in
                        self?.didSelect(items: [outputMedia])
                    }
                    self?.pushViewController(videoFiltersVC, animated: true)
                } else {
                    self?.didSelect(items: [TTDMediaItem.video(v: video)])
                }
            }
        }
    }
    
    deinit {
        print("Picker deinited 👍")
    }
    
    private func setupLoadingView() {
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        loadingView.alpha = 0
    }
}

extension TTDImagePicker: ImagePickerDelegate {
    func noPhotos() {
        self.imagePickerDelegate?.noPhotos()
    }
}
