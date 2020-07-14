import UIKit
import Foundation
import AVFoundation
import Photos


public class TTDMediaPhoto {
    
    public var image: UIImage { return modifiedImage ?? originalImage }
    public let originalImage: UIImage
    public var modifiedImage: UIImage?
    public let fromCamera: Bool
    public let exifMeta: [String: Any]?
    public var asset: PHAsset?
    
    public init(image: UIImage, exifMeta: [String: Any]? = nil, fromCamera: Bool = false, asset: PHAsset? = nil) {
        self.originalImage = image
        self.modifiedImage = nil
        self.fromCamera = fromCamera
        self.exifMeta = exifMeta
        self.asset = asset
    }
}

public class TTDMediaVideo {
    
    public var thumbnail: UIImage
    public var url: URL
    public let fromCamera: Bool
    public var asset: PHAsset?

    public init(thumbnail: UIImage, videoURL: URL, fromCamera: Bool = false, asset: PHAsset? = nil) {
        self.thumbnail = thumbnail
        self.url = videoURL
        self.fromCamera = fromCamera
        self.asset = asset
    }
}

public enum TTDMediaItem {
    case photo(p: TTDMediaPhoto)
    case video(v: TTDMediaVideo)
}

// MARK: - Compression

public extension TTDMediaVideo {
    /// Fetches a video data with selected compression in TTDImagePickerConfiguration
    func fetchData(completion: (_ videoData: Data) -> Void) {
        // TODO: place here a compression code. Use TTDConfig.videoCompression
        // and TTDConfig.videoExtension
        completion(Data())
    }
}

// MARK: - Easy access

public extension Array where Element == TTDMediaItem {
    var singlePhoto: TTDMediaPhoto? {
        if let f = first, case let .photo(p) = f {
            return p
        }
        return nil
    }
    
    var singleVideo: TTDMediaVideo? {
        if let f = first, case let .video(v) = f {
            return v
        }
        return nil
    }
}
