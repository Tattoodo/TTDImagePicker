import UIKit

public class TTDSelectionsGalleryVC: UIViewController, TTDSelectionsGalleryCellDelegate {
    
    override public var prefersStatusBarHidden: Bool { return TTDConfig.hidesStatusBar }
    
    public var items: [TTDMediaItem] = []
    public var didFinishHandler: ((_ gallery: TTDSelectionsGalleryVC, _ items: [TTDMediaItem]) -> Void)?
    private var lastContentOffsetX: CGFloat = 0
    
    var v = TTDSelectionsGalleryView()
    public override func loadView() { view = v }

    public required init(items: [TTDMediaItem],
                         didFinishHandler:
        @escaping ((_ gallery: TTDSelectionsGalleryVC, _ items: [TTDMediaItem]) -> Void)) {
        super.init(nibName: nil, bundle: nil)
        self.items = items
        self.didFinishHandler = didFinishHandler
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Register collection view cell
        v.collectionView.register(TTDSelectionsGalleryCell.self, forCellWithReuseIdentifier: "item")
        v.collectionView.dataSource = self
        v.collectionView.delegate = self
        
        // Setup navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: TTDConfig.wordings.next,
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(done))
        navigationItem.rightBarButtonItem?.tintColor = TTDConfig.colors.tintColor
        
        TTDHelper.changeBackButtonIcon(self)
        TTDHelper.changeBackButtonTitle(self)
    }

    @objc
    private func done() {
        // Save new images to the photo album.
        if TTDConfig.shouldSaveNewPicturesToAlbum {
            for m in items {
                if case let .photo(p) = m, let modifiedImage = p.modifiedImage {
                    TTDPhotoSaver.trySaveImage(modifiedImage, inAlbumNamed: TTDConfig.albumName)
                }
            }
        }
        didFinishHandler?(self, items)
    }
    
    public func selectionsGalleryCellDidTapRemove(cell: TTDSelectionsGalleryCell) {
        if let indexPath = v.collectionView.indexPath(for: cell) {
            items.remove(at: indexPath.row)
            v.collectionView.performBatchUpdates({
                v.collectionView.deleteItems(at: [indexPath])
            }, completion: { _ in })
        }
    }
}

// MARK: - Collection View
extension TTDSelectionsGalleryVC: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item",
                                                            for: indexPath) as? TTDSelectionsGalleryCell else {
            return UICollectionViewCell()
        }
        cell.delegate = self
        let item = items[indexPath.row]
        switch item {
        case .photo(let photo):
            cell.imageView.image = photo.image
            cell.setEditable(TTDConfig.showsPhotoFilters)
        case .video(let video):
            cell.imageView.image = video.thumbnail
            cell.setEditable(TTDConfig.showsVideoTrimmer)
        }
        cell.removeButton.isHidden = TTDConfig.gallery.hidesRemoveButton
        return cell
    }
}

extension TTDSelectionsGalleryVC: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        var mediaFilterVC: IsMediaFilterVC?
        switch item {
        case .photo(let photo):
            if !TTDConfig.filters.isEmpty, TTDConfig.showsPhotoFilters {
                mediaFilterVC = TTDPhotoFiltersVC(inputPhoto: photo, isFromSelectionVC: true)
            }
        case .video(let video):
            if TTDConfig.showsVideoTrimmer {
                mediaFilterVC = TTDVideoFiltersVC.initWith(video: video, isFromSelectionVC: true)
            }
        }
        
        mediaFilterVC?.didSave = { outputMedia in
            self.items[indexPath.row] = outputMedia
            collectionView.reloadData()
            self.dismiss(animated: true, completion: nil)
        }
        mediaFilterVC?.didCancel = {
            self.dismiss(animated: true, completion: nil)
        }
        if let mediaFilterVC = mediaFilterVC as? UIViewController {
            let navVC = UINavigationController(rootViewController: mediaFilterVC)
            navVC.navigationBar.isTranslucent = false
            present(navVC, animated: true, completion: nil)
        }
    }
    
    // Set "paging" behaviour when scrolling backwards.
    // This works by having `targetContentOffset(forProposedContentOffset: withScrollingVelocity` overriden
    // in the collection view Flow subclass & using UIScrollViewDecelerationRateFast
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isScrollingBackwards = scrollView.contentOffset.x < lastContentOffsetX
        scrollView.decelerationRate = isScrollingBackwards
            ? UIScrollView.DecelerationRate.fast
            : UIScrollView.DecelerationRate.normal
        lastContentOffsetX = scrollView.contentOffset.x
    }
}
