import Foundation
import AVFoundation
import UIKit

protocol TTDPhotoCapture: class {
    
    // Public api
    func start(with previewView: UIView, completion: @escaping () -> Void)
    func stopCamera()
    func focus(on point: CGPoint)
    func zoom(began: Bool, scale: CGFloat)
    func tryToggleFlash()
    var hasFlash: Bool { get }
    var currentFlashMode: TTDFlashMode { get }
    func flipCamera(completion: @escaping () -> Void)
    func shoot(completion: @escaping (Data) -> Void)
    var videoLayer: AVCaptureVideoPreviewLayer! { get set }
    var device: AVCaptureDevice? { get }
    
    // Used by Default extension
    var previewView: UIView! { get set }
    var isCaptureSessionSetup: Bool { get set }
    var isPreviewSetup: Bool { get set }
    var sessionQueue: DispatchQueue { get }
    var session: AVCaptureSession { get }
    var output: AVCaptureOutput { get }
    var deviceInput: AVCaptureDeviceInput? { get set }
    var initVideoZoomFactor: CGFloat { get set }
    func configure()
}

func newPhotoCapture() -> TTDPhotoCapture {
    PostiOS10PhotoCapture()
}

enum TTDFlashMode {
    case off
    case on
    case auto
}

extension TTDFlashMode {
    func flashImage() -> UIImage {
        switch self {
        case .on: return TTDConfig.icons.flashOnIcon
        case .off: return TTDConfig.icons.flashOffIcon
        case .auto: return TTDConfig.icons.flashAutoIcon
        }
    }
}
