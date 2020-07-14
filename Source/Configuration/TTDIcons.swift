import UIKit

public struct TTDIcons {

    public var shouldChangeDefaultBackButtonIcon = false
    public var hideBackButtonTitle = true

    public var backButtonIcon: UIImage = imageFromBundle("yp_arrow_left")
    public var arrowDownIcon: UIImage = imageFromBundle("yp_arrow_down")
    public var cropIcon: UIImage = imageFromBundle("yp_iconCrop")
    public var flashOnIcon: UIImage = imageFromBundle("flashOn")
    public var flashOffIcon: UIImage = imageFromBundle("flashOff")
    public var flashAutoIcon: UIImage = imageFromBundle("flashAuto")
    public var loopIcon: UIImage = imageFromBundle("cameraFlip")
    public var multipleSelectionOffIcon: UIImage = imageFromBundle("yp_multiple")
    public var multipleSelectionOnIcon: UIImage = imageFromBundle("yp_multiple_colored")
    public var capturePhotoImage: UIImage = imageFromBundle("takePhoto")
    public var captureVideoImage: UIImage = imageFromBundle("yp_iconVideoCapture")
    public var captureVideoOnImage: UIImage = imageFromBundle("yp_iconVideoCaptureRecording")
    public var playImage: UIImage = imageFromBundle("yp_play")
    public var removeImage: UIImage = imageFromBundle("yp_remove")
}
