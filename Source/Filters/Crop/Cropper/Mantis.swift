import UIKit

public func cropViewController(image: UIImage,
                               config: Config = Config()) -> CropViewController {
    return CropViewController(image: image,
                              config: config)
}

public func cropCustomizableViewController(image: UIImage,
                                           config: Config = Config()) -> CropViewController {
    return CropViewController(image: image,
                              config: config)
}

public func getCroppedImage(byCropInfo info: CropInfo, andImage image: UIImage) -> UIImage? {
    return image.getCroppedImage(byCropInfo: info)
}

public typealias Transformation = (
    offset: CGPoint,
    rotation: CGFloat,
    scale: CGFloat,
    manualZoomed: Bool,
    maskFrame: CGRect
)

public typealias CropInfo = (translation: CGPoint, rotation: CGFloat, scale: CGFloat, cropSize: CGSize, imageViewSize: CGSize)

public enum PresetTransformationType {
    case none
    case presetInfo(info: Transformation)
}

public enum PresetFixedRatioType {
    /** When choose alwaysUsingOnePresetFixedRatio, fixed-ratio setting button does not show.
     */
    case alwaysUsingOnePresetFixedRatio(ratio: Double)
    case canUseMultiplePresetFixedRatio
}

public enum CropShapeType {
    case rect
    
    /**
     When maskOnly is true, the cropped image is kept rect
     */
    case ellipse(maskOnly: Bool = false)

    /**
     When maskOnly is true, the cropped image is kept rect
     */
    case roundedRect(radiusToShortSide: CGFloat, maskOnly: Bool = false)
}


public struct Config {
    public var presetTransformationType: PresetTransformationType = .none
    public var cropShapeType: CropShapeType = .rect
    public var ratioOptions: RatioOptions = .all
    public var presetFixedRatioType: PresetFixedRatioType = .canUseMultiplePresetFixedRatio
    public var showRotationDial = true
    var customRatios: [(width: Int, height: Int)] = []
    
    public init() { }
        
    mutating public func addCustomRatio(byHorizontalWidth width: Int, andHorizontalHeight height: Int) {
        customRatios.append((width, height))
    }

    mutating public func addCustomRatio(byVerticalWidth width: Int, andVerticalHeight height: Int) {
        customRatios.append((height, width))
    }
    
    func hasCustomRatios() -> Bool {
        return customRatios.count > 0
    }
    
    func getCustomRatioItems() -> [RatioItemType] {
        return customRatios.map {
            (String("\($0.width):\($0.height)"), Double($0.width)/Double($0.height), String("\($0.height):\($0.width)"), Double($0.height)/Double($0.width))
        }
    }
}

