import Foundation

enum CropViewStatus {
    case initial
    case rotating(angle: CGAngle)
    case degree90Rotating
    case touchImage
    case touchRotationBoard
    case touchCropboxHandle(tappedEdge: CropViewOverlayEdge = .none)
    case betweenOperation
}
