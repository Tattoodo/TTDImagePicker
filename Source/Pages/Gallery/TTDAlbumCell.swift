import UIKit

class TTDAlbumCell: UITableViewCell {
    
    let thumbnail = UIImageView()
    let title = UILabel()
    let numberOfItems = UILabel()
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.addArrangedSubview(title)
        stackView.addArrangedSubview(numberOfItems)

        [thumbnail, stackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            thumbnail.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            thumbnail.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            thumbnail.heightAnchor.constraint(equalToConstant: 78),
            thumbnail.widthAnchor.constraint(equalToConstant: 78),
            thumbnail.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            stackView.centerYAnchor.constraint(equalTo: thumbnail.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6)
        ])
        
        thumbnail.contentMode = .scaleAspectFill
        thumbnail.clipsToBounds = true
        thumbnail.layer.cornerRadius = 4
        thumbnail.layer.masksToBounds = true
        
        title.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)
        numberOfItems.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
    }
}
