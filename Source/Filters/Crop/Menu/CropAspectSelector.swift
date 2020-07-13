import UIKit

enum CropAspect: CaseIterable {
    case original
    /// 1:1
    case square
    /// 2:3
    case twoToThree
    /// 16:9
    case sixteenToNine
    /// 3:4
    case threeToFour
    /// 10:8
    case tenToEight
    /// 7:5
    case sevenToFive
    /// 5:3
    case fiveToThree
}

class CropAspectSelector: UIView {
    var onSelectedOptionChange: (CropAspect) -> Void = { _ in }
    var onClose: () -> Void = {}

    private(set) var selectedOption: CropAspect = .square {
        didSet {
            updateSelection()
            onSelectedOptionChange(selectedOption)
            onClose()
        }
    }

    private let buttonTagOffset = 1000
    private let options: [CropAspect] = CropAspect.allCases

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

    init() {
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
        guard let idx = options.firstIndex(of: selectedOption) else { return }
        optionButtons.forEach {
            let tag = idx + buttonTagOffset
            $0.isSelected = tag == $0.tag
        }
    }

    private func buttonForAspect(option: CropAspect) -> UIButton {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setTitle(option.stringRepresentation, for: .normal)
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
 extension CropAspect {
    var stringRepresentation: String {
        switch self {
        case .original: return "Original"
        case .square: return "Square"
        case .twoToThree: return "2:3"
        case .sixteenToNine: return "16:9"
        case .threeToFour: return "3:4"
        case .tenToEight: return "10:8"
        case .sevenToFive: return "7:5"
        case .fiveToThree: return "5:3"
        }
    }
    var aspectRatio: CGFloat? {
        switch self {
        case .original: return nil
        case .square: return 1
        case .twoToThree: return 2/3
        case .sixteenToNine: return  16/9
        case .threeToFour: return 3/4
        case .tenToEight: return 10/8
        case .sevenToFive: return 7/5
        case .fiveToThree: return 5/3
        }
    }
}
