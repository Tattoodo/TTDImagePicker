import UIKit
import Photos

@available(iOS 11.0, *)
final class TTDLibraryView: UIView {
    
    let assetZoomableViewMinimalVisibleHeight: CGFloat  = 50
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var assetZoomableView: TTDAssetZoomableView!
    @IBOutlet weak var assetViewContainer: TTDAssetViewContainer!
    @IBOutlet weak var assetViewContainerConstraintTop: NSLayoutConstraint!

    private lazy var emptyViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    lazy var emptyView: EmptyView = {
       let view = EmptyView()
        view.isLayoutMarginsRelativeArrangement = true
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 40)
        return view
    }()

    lazy var maxNumberWarningView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypSecondarySystemBackground
        view.isHidden = true
        return view
    }()

    lazy var maxNumberWarningLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.font = UIFont(name: "Helvetica Neue", size: 14)
        return view
    }()

    lazy var progressView: UIProgressView =  {
        let view = UIProgressView()
        view.progressViewStyle = .bar
        view.trackTintColor = TTDConfig.colors.progressBarTrackColor
        view.progressTintColor = TTDConfig.colors.progressBarCompletedColor ?? TTDConfig.colors.tintColor
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }()

    lazy var line: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()

    var shouldShowLoader = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.contentInset.top = 4
        addSubview(line)

        NSLayoutConstraint.activate([
            line.topAnchor.constraint(equalTo: assetViewContainer.bottomAnchor),
            line.widthAnchor.constraint(equalTo: assetViewContainer.widthAnchor),
            line.centerXAnchor.constraint(equalTo: assetViewContainer.centerXAnchor)
        ])
        setupMaxNumberOfItemsView()
        setupProgressBarView()
        setupEmptyView()
    }
    
    /// At the bottom there is a view that is visible when selected a limit of items with multiple selection
    func setupMaxNumberOfItemsView() {
        maxNumberWarningView.translatesAutoresizingMaskIntoConstraints = false
        maxNumberWarningLabel.translatesAutoresizingMaskIntoConstraints = false
        maxNumberWarningView.addSubview(maxNumberWarningLabel)
        addSubview(maxNumberWarningView)
        NSLayoutConstraint.activate([
            maxNumberWarningLabel.topAnchor.constraint(equalTo: maxNumberWarningView.topAnchor, constant: 11),
            maxNumberWarningLabel.centerXAnchor.constraint(equalTo: maxNumberWarningView.centerXAnchor),
            maxNumberWarningLabel.leadingAnchor.constraint(equalTo: maxNumberWarningView.leadingAnchor, constant: 16),
            maxNumberWarningLabel.trailingAnchor.constraint(equalTo: maxNumberWarningView.trailingAnchor, constant: -16),

            maxNumberWarningView.bottomAnchor.constraint(equalTo: bottomAnchor),
            maxNumberWarningView.leadingAnchor.constraint(equalTo: leadingAnchor),
            maxNumberWarningView.trailingAnchor.constraint(equalTo: trailingAnchor),
            maxNumberWarningView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
    }
    
    /// When video is processing this bar appears
    func setupProgressBarView() {
        progressView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.heightAnchor.constraint(equalToConstant: 5),
            progressView.topAnchor.constraint(equalTo: line.topAnchor),
            progressView.widthAnchor.constraint(equalTo: line.widthAnchor),
            progressView.centerXAnchor.constraint(equalTo: line.centerXAnchor)
        ])
    }

    func setupEmptyView() {
        emptyViewContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emptyViewContainer)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyViewContainer.addSubview(emptyView)
        NSLayoutConstraint.activate([
            emptyViewContainer.topAnchor.constraint(equalTo: topAnchor),
            emptyViewContainer.widthAnchor.constraint(equalTo: widthAnchor),
            emptyViewContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            emptyViewContainer.heightAnchor.constraint(equalTo: heightAnchor),

            emptyView.centerXAnchor.constraint(equalTo: emptyViewContainer.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: emptyViewContainer.centerYAnchor),
            emptyView.leadingAnchor.constraint(equalTo: emptyViewContainer.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: emptyViewContainer.trailingAnchor)
        ])
    }

    func setEmptyState(hidden: Bool, animated: Bool = true) {
        UIView.animate(withDuration: animated ? 0.3 : 0.0) {
            self.emptyViewContainer.alpha = hidden ? 0 : 1
        }
    }
}

// MARK: - UI Helpers

extension TTDLibraryView {
    
    class func xibView() -> TTDLibraryView? {
        let bundle = Bundle(for: TTDPickerVC.self)
        let nib = UINib(nibName: "TTDLibraryView",
                        bundle: bundle)
        let xibView = nib.instantiate(withOwner: self, options: nil)[0] as? TTDLibraryView
        return xibView
    }
    
    // MARK: - Grid
    
    func hideGrid() {
        assetViewContainer.grid.alpha = 0
    }
    
    // MARK: - Loader and progress
    
    func fadeInLoader() {
        shouldShowLoader = true
        // Only show loader if full res image takes more than 0.5s to load.
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                if self.shouldShowLoader == true {
                    UIView.animate(withDuration: 0.2) {
                        self.assetViewContainer.spinnerView.alpha = 1
                    }
                }
            }
        } else {
            // Fallback on earlier versions
            UIView.animate(withDuration: 0.2) {
                self.assetViewContainer.spinnerView.alpha = 1
            }
        }
    }
    
    func hideLoader() {
        shouldShowLoader = false
        assetViewContainer.spinnerView.alpha = 0
    }
    
    func updateProgress(_ progress: Float) {
        progressView.isHidden = progress > 0.99 || progress == 0
        progressView.progress = progress
        UIView.animate(withDuration: 0.1, animations: progressView.layoutIfNeeded)
    }
    
    // MARK: - Crop Rect
    
    func currentCropRect() -> CGRect {
        guard let cropView = assetZoomableView else {
            return CGRect.zero
        }
        let normalizedX = min(1, cropView.contentOffset.x &/ cropView.contentSize.width)
        let normalizedY = min(1, cropView.contentOffset.y &/ cropView.contentSize.height)
        let normalizedWidth = min(1, cropView.frame.width / cropView.contentSize.width)
        let normalizedHeight = min(1, cropView.frame.height / cropView.contentSize.height)
        return CGRect(x: normalizedX, y: normalizedY, width: normalizedWidth, height: normalizedHeight)
    }
    
    // MARK: - Curtain
    
    func refreshImageCurtainAlpha() {
        let imageCurtainAlpha = abs(assetViewContainerConstraintTop.constant)
            / (assetViewContainer.frame.height - assetZoomableViewMinimalVisibleHeight)
        assetViewContainer.curtain.alpha = imageCurtainAlpha
    }
    
    func cellSize() -> CGSize {
        let size = UIScreen.main.bounds.width/4 * UIScreen.main.scale
        return CGSize(width: size, height: size)
    }
}
