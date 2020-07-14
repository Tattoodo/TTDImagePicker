import UIKit

final class TTDImageMenuItem: UIView {
    var selectedImage: UIImage?
    var unselectedImage: UIImage?

    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        return view
    }()

    var button = UIButton()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    func setup() {
        backgroundColor = TTDImagePickerConfiguration.shared.colors.bottomMenuItemBackgroundColor
        [imageView, button].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    func select() {
        imageView.image = selectedImage
    }

    func deselect() {
        imageView.image = unselectedImage
    }
}
