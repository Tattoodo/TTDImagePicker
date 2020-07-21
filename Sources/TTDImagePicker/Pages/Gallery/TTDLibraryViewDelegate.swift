import Foundation

@objc
public protocol TTDLibraryViewDelegate: class {
    func libraryViewDidTapNext()
    func libraryViewStartedLoadingImage()
    func libraryViewFinishedLoading()
    func libraryViewDidToggleMultipleSelection(enabled: Bool)
    func noPhotosForOptions()
    func didTapUploadImage()
    func didTapTakePicture()
}
