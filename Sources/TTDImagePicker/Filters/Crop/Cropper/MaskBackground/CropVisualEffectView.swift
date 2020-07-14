import UIKit

class CropVisualEffectView: UIVisualEffectView, CropMaskProtocol {
    var cropShapeType: CropShapeType = .rect
    
    fileprivate var translucencyEffect: UIVisualEffect?
    
    convenience init(cropShapeType: CropShapeType = .rect) {
        let translucencyEffect = UIBlurEffect(style: .light)
        self.init(effect: translucencyEffect)
        self.cropShapeType = cropShapeType
        self.translucencyEffect = translucencyEffect
        initialize()
    }
        
    func setMask() {
        let layer = createOverLayer(opacity: 0.8)
        
        let maskView = UIView(frame: self.bounds)
        maskView.clipsToBounds = true
        maskView.layer.addSublayer(layer)
        
        self.mask = maskView
    }
}
