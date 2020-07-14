import Foundation
import AVFoundation
import UIKit
import Photos

/// Typealias for code prettiness
internal var TTDConfig: TTDImagePickerConfiguration { return TTDImagePickerConfiguration.shared }

public struct TTDImagePickerConfiguration {
    public static var shared: TTDImagePickerConfiguration = TTDImagePickerConfiguration()
    
    public init() {}
    
    /// Scroll to change modes, defaults to true
    public var isScrollToChangeModesEnabled = true
    
    // Library configuration
    public var library = TTDConfigLibrary()
    
    // Video configuration
    public var video = TTDConfigVideo()
    
    // Gallery configuration
    public var gallery = TTDConfigSelectionsGallery()
    
    /// Use this property to modify the default wordings provided.
    public var wordings = TTDWordings()
    
    /// Use this property to modify the default icons provided.
    public var icons = TTDIcons()
    
    /// Use this property to modify the default colors provided.
    public var colors = TTDColors()
    
    /// Set this to true if you want to force the camera output to be a squared image. Defaults to false
    public var onlySquareImagesFromCamera = false
    
    /// Enables selecting the front camera by default, useful for avatars. Defaults to false
    public var usesFrontCamera = false
    
    /// Adds a Filter step in the photo taking process.  Defaults to true
    public var showsPhotoFilters = true
    
    /// Adds a Video Trimmer step in the video taking process.  Defaults to true
    public var showsVideoTrimmer = true
    
    /// Enables you to opt out from saving new (or old but filtered) images to the
    /// user's photo library. Defaults to true.
    public var shouldSaveNewPicturesToAlbum = true
    
    /// Defines the name of the album when saving pictures in the user's photo library.
    /// In general that would be your App name. Defaults to "DefaultTTDImagePickerAlbumName"
    public var albumName = "DefaultTTDImagePickerAlbumName"
    
    /// Defines which screen is shown at launch. Video mode will only work if `showsVideo = true`.
    /// Default value is `.photo`
    public var startOnScreen: TTDPickerScreen = .photoLibrary
    
    /// Defines which screens are shown at launch, and their order.
    /// Default value is `[.library, .photo]`
    public var screens: [TTDPickerScreen] = [.photoLibrary, .videoLibrary, .photo]

    /// Adds a Crop step in the photo taking process, after filters.  Defaults to .none
    public var showsCrop: Bool = true
    
    /// Ex: cappedTo:1024 will make sure images from the library or the camera will be
    /// resized to fit in a 1024x1024 box. Defaults to original image size.
    public var targetImageSize = TTDImageSize.original
    
    /// Adds a Overlay View to the camera
    public var overlayView: UIView?
    
    /// Defines if the status bar should be hidden when showing the picker. Default is true
    public var hidesStatusBar = true
    
    /// Defines if the bottom bar should be hidden when showing the picker. Default is false.
    public var hidesBottomBar = false

    /// Defines the preferredStatusBarAppearance
    public var preferredStatusBarStyle = UIStatusBarStyle.default
    
    /// Defines the text colour to be shown when a bottom option is selected
    public var bottomMenuItemSelectedTextColour: UIColor = .labelColor
    
    /// Defines the text colour to be shown when a bottom option is unselected
    public var bottomMenuItemUnSelectedTextColour: UIColor = .secondaryLabelColor
    
    /// Defines the max camera zoom factor for camera. Disable camera zoom with 1. Default is 1.
    public var maxCameraZoomFactor: CGFloat = 1.0
    
    /// List of default filters which will be added on the filter screen
    public var filters: [TTDFilter] = [
        TTDFilter(name: "Normal", applier: nil),
        TTDFilter(name: "Nashville", applier: TTDFilter.nashvilleFilter),
        TTDFilter(name: "Toaster", applier: TTDFilter.toasterFilter),
        TTDFilter(name: "1977", applier: TTDFilter.apply1977Filter),
        TTDFilter(name: "Clarendon", applier: TTDFilter.clarendonFilter),
        TTDFilter(name: "HazeRemoval", applier: TTDFilter.hazeRemovalFilter),
        TTDFilter(name: "Chrome", coreImageFilterName: "CIPhotoEffectChrome"),
        TTDFilter(name: "Fade", coreImageFilterName: "CIPhotoEffectFade"),
        TTDFilter(name: "Instant", coreImageFilterName: "CIPhotoEffectInstant"),
        TTDFilter(name: "Mono", coreImageFilterName: "CIPhotoEffectMono"),
        TTDFilter(name: "Noir", coreImageFilterName: "CIPhotoEffectNoir"),
        TTDFilter(name: "Process", coreImageFilterName: "CIPhotoEffectProcess"),
        TTDFilter(name: "Tonal", coreImageFilterName: "CIPhotoEffectTonal"),
        TTDFilter(name: "Transfer", coreImageFilterName: "CIPhotoEffectTransfer"),
        TTDFilter(name: "Tone", coreImageFilterName: "CILinearToSRGBToneCurve"),
        TTDFilter(name: "Linear", coreImageFilterName: "CISRGBToneCurveToLinear"),
        TTDFilter(name: "Sepia", coreImageFilterName: "CISepiaTone"),
        ]
    
    /// Migration
    
    @available(iOS, obsoleted: 3.0.0, renamed: "video.compression")
    public var videoCompression: String = AVAssetExportPresetHighestQuality
    
    @available(iOS, obsoleted: 3.0.0, renamed: "video.fileType")
    public var videoExtension: AVFileType = .mov
    
    @available(iOS, obsoleted: 3.0.0, renamed: "video.recordingTimeLimit")
    public var videoRecordingTimeLimit: TimeInterval = 60.0
    
    @available(iOS, obsoleted: 3.0.0, renamed: "video.libraryTimeLimit")
    public var videoFromLibraryTimeLimit: TimeInterval = 60.0
    
    @available(iOS, obsoleted: 3.0.0, renamed: "video.minimumTimeLimit")
    public var videoMinimumTimeLimit: TimeInterval = 3.0
    
    @available(iOS, obsoleted: 3.0.0, renamed: "video.trimmerMaxDuration")
    public var trimmerMaxDuration: Double = 60.0

    @available(iOS, obsoleted: 3.0.0, renamed: "video.trimmerMinDuration")
    public var trimmerMinDuration: Double = 3.0
    
    @available(iOS, obsoleted: 3.0.0, renamed: "library.onlySquare")
    public var onlySquareImagesFromLibrary = false
    
    @available(iOS, obsoleted: 3.0.0, renamed: "library.onlySquare")
    public var onlySquareFromLibrary = false
    
    @available(iOS, obsoleted: 3.0.0, renamed: "targetImageSize")
    public var libraryTargetImageSize = TTDImageSize.original
    
    @available(iOS, obsoleted: 3.0.0, renamed: "library.mediaType")
    public var showsVideoInLibrary = false
    
    @available(iOS, obsoleted: 3.0.0, renamed: "library.mediaType")
    public var libraryMediaType = TTDlibraryMediaType.photo
    
    @available(iOS, obsoleted: 3.0.0, renamed: "library.maxNumberOfItems")
    public var maxNumberOfItems = 1
    
}

/// Encapsulates library specific settings.
public struct TTDConfigLibrary {
    
    public var options: PHFetchOptions? = nil

    /// Set this to true if you want to force the library output to be a squared image. Defaults to false.
    public var onlySquare = false
    
    /// Sets the cropping style to square or not. Ignored if `onlySquare` is true. Defaults to true.
    public var isSquareByDefault = true
    
    /// Minimum width, to prevent selectiong too high images. Have sense if onlySquare is true and the image is portrait.
    public var minWidthForItem: CGFloat?

    /// Initial state of multiple selection button.
    public var defaultMultipleSelection = false

    /// Anything superior than 1 will enable the multiple selection feature.
    public var maxNumberOfItems = 1
    
    /// Anything greater than 1 will desactivate live photo and video modes (library only) and
    // force users to select at least the number of items defined.
    public var minNumberOfItems = 1

    /// Set the number of items per row in collection view. Defaults to 4.
    public var numberOfItemsInRow: Int = 3

    /// Set the spacing between items in collection view. Defaults to 1.0.
    public var spacingBetweenItems: CGFloat = 4.0

    /// Allow to skip the selections gallery when selecting the multiple media items. Defaults to false.
    public var skipSelectionsGallery = true
    
    /// Allow to preselected media items
    public var preselectedItems: [TTDMediaItem]?
}

/// Encapsulates video specific settings.
public struct TTDConfigVideo {
    
    /** Choose the videoCompression. Defaults to AVAssetExportPresetHighestQuality
     - "AVAssetExportPresetLowQuality"
     - "AVAssetExportPreset640x480"
     - "AVAssetExportPresetMediumQuality"
     - "AVAssetExportPreset1920x1080"
     - "AVAssetExportPreset1280x720"
     - "AVAssetExportPresetHighestQuality"
     - "AVAssetExportPresetAppleM4A"
     - "AVAssetExportPreset3840x2160"
     - "AVAssetExportPreset960x540"
     - "AVAssetExportPresetPassthrough" // without any compression
     */
    public var compression: String = AVAssetExportPresetHighestQuality
    
    /// Choose the result video extension if you trim or compress a video. Defaults to mov.
    public var fileType: AVFileType = .mov
    
    /// Defines the time limit for recording videos.
    /// Default is 60 seconds.
    public var recordingTimeLimit: TimeInterval = 60.0
    
    /// Defines the time limit for videos from the library.
    /// Defaults to 60 seconds.
    public var libraryTimeLimit: TimeInterval = 60.0
    
    /// Defines the minimum time for the video
    /// Defaults to 3 seconds.
    public var minimumTimeLimit: TimeInterval = 3.0
    
    /// The maximum duration allowed for the trimming. Change it before setting the asset, as the asset preview
    public var trimmerMaxDuration: Double = 60.0
    
    /// The minimum duration allowed for the trimming.
    /// The handles won't pan further if the minimum duration is attained.
    public var trimmerMinDuration: Double = 3.0
}

/// Encapsulates gallery specific settings.
public struct TTDConfigSelectionsGallery {
    /// Defines if the remove button should be hidden when showing the gallery. Default is true.
    public var hidesRemoveButton = true
}

public enum TTDlibraryMediaType {
    case photo
    case video
    case photoAndVideo
}
