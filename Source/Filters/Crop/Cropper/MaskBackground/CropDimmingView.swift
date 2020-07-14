import UIKit

class CropDimmingView: UIView, CropMaskProtocol {
    var cropShapeType: CropShapeType = .rect
    
    convenience init(cropShapeType: CropShapeType = .rect) {
        self.init(frame: CGRect.zero)
        self.cropShapeType = cropShapeType
        initialize()
    }
    
    func setMask() {
        let layer = createOverLayer(opacity: 0.5)
        self.layer.addSublayer(layer)
    }
}
