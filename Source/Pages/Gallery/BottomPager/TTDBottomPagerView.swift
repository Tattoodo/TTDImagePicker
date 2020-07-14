import UIKit

final class TTDBottomPagerView: UIView {
    var headerBottomConstraint: NSLayoutConstraint!
    var header = TTDPagerMenu()
    var scrollView = UIScrollView()
    
    convenience init() {
        self.init(frame: .zero)
        backgroundColor = .red
        [scrollView, header].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        headerBottomConstraint =  header.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),

            header.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
            headerBottomConstraint,
            header.heightAnchor.constraint(equalToConstant: (TTDConfig.hidesBottomBar || (TTDConfig.screens.count == 1)) ? 0 : 44),
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            header.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
        ])
        clipsToBounds = false
        setupScrollView()
    }

    private func setupScrollView() {
        scrollView.clipsToBounds = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.bounces = false
    }
}
