import UIKit

class CropToolbarMenu: UIView {
    var onAspectRatioChange: (CropAspect) -> () = { _ in }
    var selectedApsectRatio: CropAspect { aspectSelector.selectedOption }

    private lazy var aspectSelector: CropAspectSelector = {
        CropAspectSelector()
    }()

    private lazy var hStack: UIStackView = {
        let view = UIStackView()
        view.addArrangedSubview(aspectRatioStack)
        view.addArrangedSubview(flipIcon)
        view.addArrangedSubview(rotateView)
        view.alignment = .center
        view.distribution = .equalCentering
        view.isLayoutMarginsRelativeArrangement = true
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24)
        return view
    }()

    private lazy var aspectRatioStack: UIStackView = {
        let view = UIStackView()
        view.spacing = 8
        view.alignment = .center
        view.addArrangedSubview(aspectIcon)
        view.addArrangedSubview(aspectRatioLabel)
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(openSelector))
        view.addGestureRecognizer(tap)
        return view
    }()

    private lazy var aspectRatioLabel: UILabel = {
        let view = UILabel()
        view.textColor = .ypLabel
        view.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return view
    }()

    private lazy var aspectIcon: UIImageView = {
        let view = UIImageView(image: imageFromBundle("aspectRatioIcon"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 22).isActive = true
        view.widthAnchor.constraint(equalToConstant: 22).isActive = true
        return view
    }()

    private lazy var flipIcon: UIImageView = {
        let view = UIImageView(image: imageFromBundle("flipImage"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 22).isActive = true
        view.widthAnchor.constraint(equalToConstant: 22).isActive = true
        return view
    }()

    private lazy var rotateView: UIImageView = {
        let view = UIImageView(image: imageFromBundle("rotateImage"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 22).isActive = true
        view.widthAnchor.constraint(equalToConstant: 22).isActive = true
        return view
    }()

    init() {
        super.init(frame: .zero)
        setupViews()
        aspectSelector.onSelectedOptionChange = { [weak self] option in
            self?.aspectRatioLabel.text = option.stringRepresentation
            self?.onAspectRatioChange(option)
        }
        aspectSelector.onClose = { [weak self] in
            self?.setAspectSelector(isShowing: false)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setAspectSelector(isShowing: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            self.hStack.alpha = isShowing ? 0 : 1
            self.aspectSelector.alpha = isShowing ? 1 : 0
        }, completion: nil)
    }

    private func setupViews() {
        hStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hStack)
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            hStack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            hStack.heightAnchor.constraint(equalToConstant: 40),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        aspectSelector.translatesAutoresizingMaskIntoConstraints = false
        addSubview(aspectSelector)
        NSLayoutConstraint.activate([
            aspectSelector.leadingAnchor.constraint(equalTo: leadingAnchor),
            aspectSelector.trailingAnchor.constraint(equalTo: trailingAnchor),
            aspectSelector.centerYAnchor.constraint(equalTo: hStack.centerYAnchor)
        ])
        aspectRatioLabel.text = aspectSelector.selectedOption.stringRepresentation
        aspectSelector.alpha = 0
    }

    @objc private func openSelector() {
        setAspectSelector(isShowing: true)
    }
}
