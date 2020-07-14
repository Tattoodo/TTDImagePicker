import UIKit

class TTDAlbumView: UIView {
    
    let tableView = UITableView()
    let spinner = UIActivityIndicatorView(style: .gray)
    
    convenience init() {
        self.init(frame: .zero)
        [tableView, spinner].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        // TableView needs to be the first subview for it to automatically adjust its content inset with the NavBar
        NSLayoutConstraint.activate([
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        backgroundColor = .systemBackgroundColor
    }
}
