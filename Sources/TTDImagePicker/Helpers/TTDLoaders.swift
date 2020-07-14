import UIKit

struct TTDLoaders {

    static var defaultLoader: UIBarButtonItem {
        let spinner = UIActivityIndicatorView(style: .gray)
        if let spinnerColor = TTDConfig.colors.navigationBarActivityIndicatorColor {
            spinner.color = spinnerColor
        } else {
            if #available(iOS 13, *) {
                let spinnerColor = UIColor { trait -> UIColor in
                    return trait.userInterfaceStyle == .dark ? .white : .gray
                }
                spinner.color = spinnerColor
            }
        }
        spinner.startAnimating()
        return UIBarButtonItem(customView: spinner)
    }
}
