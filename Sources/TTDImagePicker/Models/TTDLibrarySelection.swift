import UIKit

struct TTDLibrarySelection {
    let index: Int
    var cropRect: CGRect?
    var scrollViewContentOffset: CGPoint?
    var scrollViewZoomScale: CGFloat?
    let assetIdentifier: String
    
    init(index: Int,
         cropRect: CGRect? = nil,
         scrollViewContentOffset: CGPoint? = nil,
         scrollViewZoomScale: CGFloat? = nil,
         assetIdentifier: String) {
        self.index = index
        self.cropRect = cropRect
        self.scrollViewContentOffset = scrollViewContentOffset
        self.scrollViewZoomScale = scrollViewZoomScale
        self.assetIdentifier = assetIdentifier
    }
}
