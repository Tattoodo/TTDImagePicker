import Foundation

public struct TTDWordings {
    
    public var permissionPopup = PermissionPopup()
    public var videoDurationPopup = VideoDurationPopup()

    public struct PermissionPopup {
        public var title = localized("TTDImagePickerPermissionDeniedPopupTitle")
        public var message = localized("TTDImagePickerPermissionDeniedPopupMessage")
        public var cancel = localized("TTDImagePickerPermissionDeniedPopupCancel")
        public var grantPermission = localized("TTDImagePickerPermissionDeniedPopupGrantPermission")
    }
    
    public struct VideoDurationPopup {
        public var title = localized("TTDImagePickerVideoDurationTitle")
        public var tooShortMessage = localized("TTDImagePickerVideoTooShort")
        public var tooLongMessage = localized("TTDImagePickerVideoTooLong")
    }
    
    public var ok = localized("TTDImagePickerOk")
    public var done = localized("TTDImagePickerDone")
    public var cancel = localized("TTDImagePickerCancel")
    public var save = localized("TTDImagePickerSave")
    public var processing = localized("TTDImagePickerProcessing")
    public var trim = localized("TTDImagePickerTrim")
    public var cover = localized("TTDImagePickerCover")
    public var albumsTitle = localized("TTDImagePickerAlbums")
    public var libraryTitle = localized("TTDImagePickerLibrary")
    public var cameraTitle = localized("TTDImagePickerPhoto")
    public var videoTitle = localized("TTDImagePickerVideo")
    public var next = localized("TTDImagePickerNext")
    public var filter = localized("TTDImagePickerFilter")
    public var crop = localized("TTDImagePickerCrop")
    public var warningMaxItemsLimit = localized("TTDImagePickerWarningItemsLimit")
}
