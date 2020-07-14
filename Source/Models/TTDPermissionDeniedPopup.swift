import UIKit

class TTDPermissionDeniedPopup {
    func popup(cancelBlock: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(title:
            TTDConfig.wordings.permissionPopup.title,
                                      message: TTDConfig.wordings.permissionPopup.message,
                                      preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: TTDConfig.wordings.permissionPopup.cancel,
                          style: UIAlertAction.Style.cancel,
                          handler: { _ in
                            cancelBlock()
            }))
        alert.addAction(
            UIAlertAction(title: TTDConfig.wordings.permissionPopup.grantPermission,
                          style: .default,
                          handler: { _ in
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                            } else {
                                UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                            }
            }))
        return alert
    }
}
