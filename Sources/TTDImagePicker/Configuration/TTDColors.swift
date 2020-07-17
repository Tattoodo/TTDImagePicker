import UIKit

public struct TTDColors {
    
    // MARK: - Common
    
    /// The common tint color which is used for done buttons in navigation bar, multiple items selection and so on.
    public var tintColor = UIColor.ypSystemBlue

    /// The tint color which is used for cancel buttons in navigation bar, etc.
    public var secondaryTintColor: UIColor = .labelColor
    
    /// A color for navigation bar spinner.
    /// Default is nil, which is default iOS gray UIActivityIndicator.
    public var navigationBarActivityIndicatorColor: UIColor?
    
    /// A color for circle for selected items in multiple selection
    /// Default is nil, which takes tintColor.
    public var multipleItemsSelectedCircleColor: UIColor?
    
    /// The background color of the bottom of photo and video screens.
    public var photoVideoScreenBackgroundColor: UIColor = .offWhiteOrBlack

    /// The background color of the library and space between collection view cells.
    public var libraryScreenBackgroundColor: UIColor = .offWhiteOrBlack

    /// The background color of safe area. For example under the menu items.
    public var safeAreaBackgroundColor: UIColor = .offWhiteOrBlack

    /// A color for background of the asset container. You can see it when bouncing the image.
    public var assetViewBackgroundColor: UIColor = .offWhiteOrBlack
    
    /// A color for background in filters.
    public var filterBackgroundColor: UIColor = .offWhiteOrBlack

    /// A color for background in selections gallery. When multiple items selected.
    public var selectionsBackgroundColor: UIColor = .offWhiteOrBlack

    /// A color for bottom buttons (photo, video, all photos).
    public var bottomMenuItemBackgroundColor: UIColor = .clear

    /// A color for for bottom buttons selected text.
    public var bottomMenuItemSelectedTextColor: UIColor = .labelColor

    /// A color for for bottom buttons not selected text.
    public var bottomMenuItemUnselectedTextColor: UIColor = .secondaryLabelColor

    // MARK: - Trimmer
    /// The color of the main border of the view
    public var trimmerMainColor: UIColor = .labelColor
    /// The color of the handles on the side of the view
    public var trimmerHandleColor: UIColor = .systemBackgroundColor
    /// The color of the position indicator
    public var positionLineColor: UIColor = .systemBackgroundColor
    
    // MARK: - Cover selector
    
    /// The color of the cover selector border
    public var coverSelectorBorderColor: UIColor = .offWhiteOrBlack
    
    // MARK: - Progress bar
    
    /// The color for the progress bar when processing video or images. The all track color.
    public var progressBarTrackColor: UIColor = .systemBackgroundColor
    /// The color of completed track for the progress bar
    public var progressBarCompletedColor: UIColor?
}
