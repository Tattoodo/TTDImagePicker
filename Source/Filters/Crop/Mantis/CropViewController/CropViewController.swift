import UIKit


public class CropViewController: UIViewController {

    public var didFinishCropping: ((Swift.Result<UIImage, Error>) -> Void)?
    /// When a CropViewController is used in a storyboard,
    /// passing an image to it is needed after the CropViewController is created.
    public var image: UIImage! {
        didSet {
            cropView.image = image
        }
    }

    public var config = Config()
    
    private var orientation: UIInterfaceOrientation = .unknown
    private lazy var cropView = CropView(image: image, viewModel: CropViewModel())
    private lazy var fixedRatioManager: FixedRatioManager = { getFixedRatioManager() }()
    private lazy var cropToolbar: CropToolbarMenu = { CropToolbarMenu(ratioManager: fixedRatioManager) }()
    private var ratioPresenter: RatioPresenter?
    private var stackView: UIStackView?
    private var initialLayout = false
    private var disableRotation = false
    
    deinit {
        print("CropViewController deinit.")
    }
    
    init(image: UIImage,
         config: Config = Config()) {
        self.image = image
        self.config = config
        super.init(nibName: nil, bundle: nil)
        setupCropToolbarActions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
        
    fileprivate func setupCropToolbarActions() {
        cropToolbar.onAspectRatioChange = { [weak self] ratio in
            self?.setFixedRatio(ratio)
        }

        cropToolbar.onResetActionTap = { [weak self] in
            self?.handleReset()
        }

        cropToolbar.onFlipAction = { [weak self] in
            self?.handleRotate(rotateAngle: .pi)
        }
    }
        
    fileprivate func getFixedRatioManager() -> FixedRatioManager {
        let type: RatioType = cropView.getRatioType(byImageIsOriginalisHorizontal: cropView.image.isHorizontal())
        
        let ratio = cropView.getImageRatioH()
        
        return FixedRatioManager(type: type,
                                 originalRatioH: ratio,
                                 ratioOptions: config.ratioOptions,
                                 customRatios: config.getCustomRatioItems())
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        createCropView()
        initLayout()

        let cancelButton = UIBarButtonItem(title: YPConfig.wordings.cancel,
                                           style: .plain,
                                           target: self,
                                           action: #selector(cancel))

        let saveButton = UIBarButtonItem(title: YPConfig.wordings.save,
                                           style: .plain,
                                           target: self,
                                           action: #selector(done))

        navigationItem.rightBarButtonItem = saveButton
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.title = ypLocalized("YPImagePickerCrop")

    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if initialLayout == false {
            initialLayout = true
            view.layoutIfNeeded()
            cropView.adaptForCropBox()
        }
    }
    
    public override var prefersStatusBarHidden: Bool { false }
    public override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { return [.top, .bottom] }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        cropView.prepareForDeviceRotation()
    }
    
    func setFixedRatio(_ ratio: Double) {
        cropView.aspectRatioLockEnabled = true
        guard (cropView.viewModel.aspectRatio != CGFloat(ratio))  else { return }
        cropView.viewModel.aspectRatio = CGFloat(ratio)
        UIView.animate(withDuration: 0.5) {
            self.cropView.setFixedRatioCropBox()
        }
    }

    private func createCropView() {
        if !config.showRotationDial {
            cropView.angleDashboardHeight = 0
        }
        cropView.delegate = self
        cropView.clipsToBounds = true
        cropView.cropShapeType = config.cropShapeType
        
        if case .alwaysUsingOnePresetFixedRatio = config.presetFixedRatioType {
            cropView.forceFixedRatio = true
        } else {
            cropView.forceFixedRatio = false
        }
    }
        
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if case .presetInfo(let transformInfo) = config.presetTransformationType {
            cropView.transform(byTransformInfo: transformInfo)
        }
    }

    
    private func resetRatioButton() {
        cropView.aspectRatioLockEnabled = false
    }
    
    private func handleReset() {
        resetRatioButton()
        cropView.reset()
    }
    
    private func handleRotate(rotateAngle: CGFloat) {
        if !disableRotation {
            disableRotation = true
            cropView.RotateBy90(rotateAngle: rotateAngle) { [weak self] in
                self?.disableRotation = false
            }
        }
    }
    
    private func handleCrop() {
        let cropResult = cropView.crop()
        guard let image = cropResult.croppedImage else {
            didFinishCropping?(.failure(CropperError.failed(originalImage: cropView.image)))
            return
        }
        didFinishCropping?(.success(image))
    }
}

// Auto layout
extension CropViewController {
    fileprivate func initLayout() {
        stackView = UIStackView()
        stackView?.axis = .vertical
        view.addSubview(stackView!)
        cropToolbar.backgroundColor = .red
        stackView?.translatesAutoresizingMaskIntoConstraints = false
        cropToolbar.translatesAutoresizingMaskIntoConstraints = false
        cropView.translatesAutoresizingMaskIntoConstraints = false
        cropToolbar.heightAnchor.constraint(equalToConstant: 64).isActive = true

        stackView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        stackView?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        stackView?.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        stackView?.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true

        stackView?.addArrangedSubview(cropView)
        stackView?.addArrangedSubview(cropToolbar)
    }

    @objc func done() {
        handleCrop()
    }

    @objc func cancel() {
        navigationController?.popViewController(animated: true)
    }
}

extension CropViewController: CropViewDelegate {
    func cropViewDidBecomeResettable(_ cropView: CropView) {
        cropToolbar.setAsResettable()
    }
    
    func cropViewDidBecomeUnResettable(_ cropView: CropView) {
        cropToolbar.setAsUnResettable()
    }
}

//extension CropViewController: CropToolbarDelegate {
//    public func didSelectCancel() {
////        handleCancel()
//    }
//
//    public func didSelectCrop() {
//        handleCrop()
//    }
//
//    public func didSelectCounterClockwiseRotate() {
//        handleRotate(rotateAngle: -CGFloat.pi / 2)
//    }
//
//    public func didSelectClockwiseRotate() {
//        handleRotate(rotateAngle: CGFloat.pi / 2)
//    }
//
//    public func didSelectReset() {
//        handleReset()
//    }
//
//    public func didSelectSetRatio() {
//        handleSetRatio()
//    }
//}

// API
extension CropViewController {
    public func crop() {
        let cropResult = cropView.crop()
        guard let image = cropResult.croppedImage else {
            didFinishCropping?(.failure(CropperError.failed(originalImage: cropView.image)))
            return
        }
        didFinishCropping?(.success(image))
    }
    
    public func process(_ image: UIImage) -> UIImage? {
        return cropView.crop(image).croppedImage
    }
}

enum CropperError: Error {
    case failed(originalImage: UIImage)
}
