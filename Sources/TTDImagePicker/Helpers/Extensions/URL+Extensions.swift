import UIKit

extension URL {
    /// Adds a unique path to url
    func appendingUniquePathComponent(pathExtension: String? = nil) -> URL {
        var pathComponent = UUID().uuidString
        if let pathExtension = pathExtension {
            pathComponent += ".\(pathExtension)"
        }
        return appendingPathComponent(pathComponent)
    }
}
