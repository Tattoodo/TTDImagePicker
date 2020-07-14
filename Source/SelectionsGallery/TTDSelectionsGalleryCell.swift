import UIKit

public protocol TTDSelectionsGalleryCellDelegate: class {
    func selectionsGalleryCellDidTapRemove(cell: TTDSelectionsGalleryCell)
}

public class TTDSelectionsGalleryCell: UICollectionViewCell {
    
    weak var delegate: TTDSelectionsGalleryCellDelegate?
    let imageView = UIImageView()
    let editIcon = UIView()
    let editSquare = UIView()
    let removeButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        [imageView, editIcon, editSquare, removeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            editIcon.heightAnchor.constraint(equalToConstant: 32),
            editIcon.widthAnchor.constraint(equalToConstant: 32),
            editIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            editIcon.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            editSquare.heightAnchor.constraint(equalToConstant: 16),
            editSquare.widthAnchor.constraint(equalToConstant: 16),
            editSquare.centerYAnchor.constraint(equalTo: editIcon.centerYAnchor),
            editSquare.centerXAnchor.constraint(equalTo: editIcon.centerXAnchor),

            removeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            removeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
        ])

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 4, height: 7)
        layer.shadowRadius = 5
        layer.backgroundColor = UIColor.clear.cgColor

        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        editIcon.backgroundColor = UIColor.ypSystemBackground
        editIcon.layer.cornerRadius = 16
        editSquare.layer.borderWidth = 1
        editSquare.layer.borderColor = UIColor.ypLabel.cgColor

        removeButton.setImage(TTDConfig.icons.removeImage, for: .normal)
        removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
    }
    
    @objc
    func removeButtonTapped() {
        delegate?.selectionsGalleryCellDidTapRemove(cell: self)
    }
    
    func setEditable(_ editable: Bool) {
        self.editIcon.isHidden = !editable
        self.editSquare.isHidden = !editable
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0,
                           options: .curveEaseInOut,
                           animations: {
                            if self.isHighlighted {
                                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                                self.alpha = 0.8
                            } else {
                                self.transform = .identity
                                self.alpha = 1
                            }
            }, completion: nil)
        }
    }
}
