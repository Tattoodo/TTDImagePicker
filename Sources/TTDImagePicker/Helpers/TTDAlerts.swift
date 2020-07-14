import UIKit

struct TTDAlert {
    static func videoTooLongAlert(_ sourceView: UIView) -> UIAlertController {
        let msg = String(format: TTDConfig.wordings.videoDurationPopup.tooLongMessage,
                         "\(TTDConfig.video.libraryTimeLimit)")
        let alert = UIAlertController(title: TTDConfig.wordings.videoDurationPopup.title,
                                      message: msg,
                                      preferredStyle: .actionSheet)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sourceView
            popoverController.sourceRect = CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        alert.addAction(UIAlertAction(title: TTDConfig.wordings.ok, style: UIAlertAction.Style.default, handler: nil))
        return alert
    }
    
    static func videoTooShortAlert(_ sourceView: UIView) -> UIAlertController {
        let msg = String(format: TTDConfig.wordings.videoDurationPopup.tooShortMessage,
                         "\(TTDConfig.video.minimumTimeLimit)")
        let alert = UIAlertController(title: TTDConfig.wordings.videoDurationPopup.title,
                                      message: msg,
                                      preferredStyle: .actionSheet)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sourceView
            popoverController.sourceRect = CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        alert.addAction(UIAlertAction(title: TTDConfig.wordings.ok, style: UIAlertAction.Style.default, handler: nil))
        return alert
    }
}
