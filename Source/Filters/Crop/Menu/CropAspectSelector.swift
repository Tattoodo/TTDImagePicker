import UIKit

class CropAspectSelector: UIView {
    private let ratioManager: FixedRatioManager
    private var isHorizontal: Bool { ratioManager.type == .horizontal }
    var onSelectedRatioChanged: (_ ratio: Double, _ name: String) -> Void = { _,_ in }
    var onClose: () -> Void = {}

    private(set) var selectedOption: RatioItemType {
        didSet {
            updateSelection()
            let ratio = isHorizontal ? selectedOption.ratioH : selectedOption.ratioV
            let name = isHorizontal ? selectedOption.nameH : selectedOption.nameV
            onSelectedRatioChanged(ratio, name)
            onClose()
        }
    }

    private let buttonTagOffset = 1000
    private var options: [RatioItemType] { ratioManager.ratios }

    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.contentInset.left = 24
        view.showsHorizontalScrollIndicator = false
        return view
    }()

    lazy var hStack: UIStackView = {
        let view = UIStackView()
        view.spacing = 24
        view.alignment = .center
        return view
    }()

    lazy var closeButton: UIButton = {
        let view = UIButton()
        view.setImage(imageFromBundle("roundXButton"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        view.widthAnchor.constraint(equalToConstant: 40).isActive = true
        view.addTarget(self, action: #selector(closeButtonTapAction), for: .touchUpInside)
        return view
    }()

    init(ratioManager: FixedRatioManager) {
        self.ratioManager = ratioManager
        selectedOption = ratioManager.getOriginalRatioItem()
        super.init(frame: .zero)
        setupViews()
        setupData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        hStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(hStack)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            hStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hStack.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }

    private var optionButtons: [UIButton] = []

    private func setupData() {
        hStack.addArrangedSubview(closeButton)
        for (idx, option) in options.enumerated() {
            let button = buttonForAspect(option: option)
            button.tag = idx + buttonTagOffset
            optionButtons.append(button)
            hStack.addArrangedSubview(button)
        }
    }

    private func updateSelection() {
        guard let idx = options.firstIndex(where: { $0.nameV == selectedOption.nameV }) else { return }
        optionButtons.forEach {
            let tag = idx + buttonTagOffset
            $0.isSelected = tag == $0.tag
        }
    }

    private func buttonForAspect(option: RatioItemType) -> UIButton {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setTitle(isHorizontal ? option.nameH : option.nameV, for: .normal)
        button.setTitleColor(.ypLabel, for: .selected)
        button.setTitleColor(.ypSecondaryLabel, for: .normal)
        button.isSelected = option == selectedOption
        button.addTarget(self, action: #selector(optionButtonTapAction(sender:)), for: .touchUpInside)
        return button
    }

    @objc private func optionButtonTapAction(sender: UIButton) {
        let idx = sender.tag - buttonTagOffset
        selectedOption = options[idx]
    }

    @objc private func closeButtonTapAction() {
        onClose()
    }
}
