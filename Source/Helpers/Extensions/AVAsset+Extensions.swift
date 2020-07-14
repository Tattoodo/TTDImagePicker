import AVFoundation

// MARK: Trim

extension AVAsset {
    func assetByTrimming(startTime: CMTime, endTime: CMTime) throws -> AVAsset {
        let timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
        let composition = AVMutableComposition()
        do {
            for track in tracks {
                let compositionTrack = composition.addMutableTrack(withMediaType: track.mediaType,
                                                                   preferredTrackID: track.trackID)
                try compositionTrack?.insertTimeRange(timeRange, of: track, at: CMTime.zero)
            }
        } catch let error {
            throw TTDTrimError("Error during composition", underlyingError: error)
        }
        
        // Reaply correct transform to keep original orientation.
        if let videoTrack = self.tracks(withMediaType: .video).last,
            let compositionTrack = composition.tracks(withMediaType: .video).last {
            compositionTrack.preferredTransform = videoTrack.preferredTransform
        }

        return composition
    }
    
    /// Export the video
    ///
    /// - Parameters:
    ///   - destination: The url to export
    ///   - videoComposition: video composition settings, for example like crop
    ///   - removeOldFile: remove old video
    ///   - completion: resulting export closure
    /// - Throws: TTDTrimError with description
    func export(to destination: URL,
                videoComposition: AVVideoComposition? = nil,
                removeOldFile: Bool = false,
                completion: @escaping (_ exportSession: AVAssetExportSession) -> Void) -> AVAssetExportSession? {
        guard let exportSession = AVAssetExportSession(asset: self, presetName: TTDConfig.video.compression) else {
            print("TTDImagePicker -> AVAsset -> Could not create an export session.")
            return nil
        }
        
        exportSession.outputURL = destination
        exportSession.outputFileType = TTDConfig.video.fileType
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.videoComposition = videoComposition
        
        if removeOldFile { try? FileManager.default.removeFileIfNecessary(at: destination) }
        
        exportSession.exportAsynchronously(completionHandler: {
            completion(exportSession)
        })

        return exportSession
    }
}
