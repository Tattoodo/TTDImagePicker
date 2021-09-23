import UIKit

@available(iOS 11.0, *)
class EmptyView: UIStackView {
    var onTap: () -> Void = {}

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = TTDConfig.colors.emptyViewTitleTextColor
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = TTDConfig.colors.emptyViewMessageTextColor
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    lazy var imageViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = TTDConfig.colors.emptyViewImageContainerColor
        view.layer.cornerRadius = 77/2
        return view
    }()

    lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()

    lazy var button: UIButton = {
        let view = UIButton()
        view.setTitleColor(TTDConfig.colors.emptyViewButtonTitleColor, for: .normal)
        view.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        view.layer.cornerRadius = 18
        view.contentEdgeInsets = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 60)
        view.layer.borderColor = TTDConfig.colors.emptyViewButtonBorderColor.cgColor
        view.layer.borderWidth = 1
        view.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return view
    }()

    init() {
        super.init(frame: .zero)
        setupViews()
    }

    func set(title: String, message: String, buttonTitle: String, icon: UIImage) {
        titleLabel.text = title
        messageLabel.text = message
        imageView.image = icon
        button.setTitle(buttonTitle, for: .normal)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        axis = .vertical
        alignment = .center
        spacing = 16
        addArrangedSubview(imageViewContainer)
        addArrangedSubview(titleLabel)
        addArrangedSubview(messageLabel)
        addArrangedSubview(button)
        setCustomSpacing(8, after: titleLabel)
        setCustomSpacing(24, after: messageLabel)

        imageViewContainer.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageViewContainer.addSubview(imageView)
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageViewContainer.heightAnchor.constraint(equalToConstant: 77),
            imageViewContainer.widthAnchor.constraint(equalToConstant: 77),

            imageView.centerYAnchor.constraint(equalTo: imageViewContainer.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: imageViewContainer.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 32),
            imageView.widthAnchor.constraint(equalToConstant: 36),

            button.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    @objc private func buttonAction() {
        onTap()
    }
}
