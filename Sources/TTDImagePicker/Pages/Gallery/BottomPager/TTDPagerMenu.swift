import UIKit

final class TTDPagerMenu: UIView { //TODO: selected segment control
    var bottomConstraint: NSLayoutConstraint!
    var didSetConstraints = false
    var menuItems = [TTDImageMenuItem]()
    private var selectedIndicatorCenterXConstraint: NSLayoutConstraint?

    private lazy var topBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = TTDConfig.colors.emptyViewImageContainerColor
        return view
    }()

    lazy var selectedIndicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()

    convenience init() {
        self.init(frame: .zero)
        backgroundColor = .white
        clipsToBounds = true
    }


    func setUpMenuItemsConstraints() {
        let menuItemWidth: CGFloat = UIScreen.main.bounds.width / CGFloat(menuItems.count)
        topBorderView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topBorderView)
        NSLayoutConstraint.activate([
            topBorderView.heightAnchor.constraint(equalToConstant: 1),
            topBorderView.topAnchor.constraint(equalTo: topAnchor),
            topBorderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topBorderView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        var previousMenuItem: TTDImageMenuItem?
        for m in menuItems {
            m.translatesAutoresizingMaskIntoConstraints = false
            addSubview(m)
            NSLayoutConstraint.activate([
                m.topAnchor.constraint(equalTo: topBorderView.bottomAnchor),
                m.bottomAnchor.constraint(equalTo: bottomAnchor),
                m.widthAnchor.constraint(equalToConstant: menuItemWidth)
            ])
            if let pm = previousMenuItem {
                NSLayoutConstraint.activate([ m.leadingAnchor.constraint(equalTo: pm.trailingAnchor, constant: 0)])
            } else {
                NSLayoutConstraint.activate([ m.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)])
            }
            previousMenuItem = m
        }
        menuItems.forEach {
            $0.onSelected = { [weak self] selectedItem in
                self?.updateSelectedIndicatorXConstraint(selectedItem)
            }
        }
        addSubview(selectedIndicatorView)
        NSLayoutConstraint.activate([
            selectedIndicatorView.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width / 3.0)/2),
            selectedIndicatorView.heightAnchor.constraint(equalToConstant: 1),
            selectedIndicatorView.topAnchor.constraint(equalTo: topBorderView.bottomAnchor)
        ])
    }

    private func updateSelectedIndicatorXConstraint(_ view: UIView) {
        if let prev = selectedIndicatorCenterXConstraint {
            NSLayoutConstraint.deactivate([prev])
        }
        selectedIndicatorCenterXConstraint = selectedIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        selectedIndicatorCenterXConstraint?.isActive = true
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }

    override func updateConstraints() {
        super.updateConstraints()
        if !didSetConstraints {
            setUpMenuItemsConstraints()
        }
        didSetConstraints = true
    }
    
    func refreshMenuItems() {
        didSetConstraints = false
        updateConstraints()
    }
}
