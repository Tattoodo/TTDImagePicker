import Foundation

public struct TTDWordings {
    
    public var permissionPopup = PermissionPopup()
    public var videoDurationPopup = VideoDurationPopup()

    public struct PermissionPopup {
        public var title = ypLocalized("TTDImagePickerPermissionDeniedPopupTitle")
        public var message = ypLocalized("TTDImagePickerPermissionDeniedPopupMessage")
        public var cancel = ypLocalized("TTDImagePickerPermissionDeniedPopupCancel")
        public var grantPermission = ypLocalized("TTDImagePickerPermissionDeniedPopupGrantPermission")
    }
    
    public struct VideoDurationPopup {
        public var title = ypLocalized("TTDImagePickerVideoDurationTitle")
        public var tooShortMessage = ypLocalized("TTDImagePickerVideoTooShort")
        public var tooLongMessage = ypLocalized("TTDImagePickerVideoTooLong")
    }
    
    public var ok = ypLocalized("TTDImagePickerOk")
    public var done = ypLocalized("TTDImagePickerDone")
    public var cancel = ypLocalized("TTDImagePickerCancel")
    public var save = ypLocalized("TTDImagePickerSave")
    public var processing = ypLocalized("TTDImagePickerProcessing")
    public var trim = ypLocalized("TTDImagePickerTrim")
    public var cover = ypLocalized("TTDImagePickerCover")
    public var albumsTitle = ypLocalized("TTDImagePickerAlbums")
    public var libraryTitle = ypLocalized("TTDImagePickerLibrary")
    public var cameraTitle = ypLocalized("TTDImagePickerPhoto")
    public var videoTitle = ypLocalized("TTDImagePickerVideo")
    public var next = ypLocalized("TTDImagePickerNext")
    public var filter = ypLocalized("TTDImagePickerFilter")
    public var crop = ypLocalized("TTDImagePickerCrop")
    public var warningMaxItemsLimit = ypLocalized("TTDImagePickerWarningItemsLimit")
}
