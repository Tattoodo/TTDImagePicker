import UIKit

final class TTDPagerMenu: UIView { //TODO: selected segment control
    var bottomConstraint: NSLayoutConstraint!
    var didSetConstraints = false
    var menuItems = [TTDImageMenuItem]()
    
    convenience init() {
        self.init(frame: .zero)
        backgroundColor = .offWhiteOrBlack
        clipsToBounds = true
    }
    
    var separators = [UIView]()
    
    func setUpMenuItemsConstraints() {
        let menuItemWidth: CGFloat = UIScreen.main.bounds.width / CGFloat(menuItems.count)
        var previousMenuItem: TTDImageMenuItem?
        for m in menuItems {
            m.translatesAutoresizingMaskIntoConstraints = false
            addSubview(m)

            NSLayoutConstraint.activate([
                m.topAnchor.constraint(equalTo: topAnchor),
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
