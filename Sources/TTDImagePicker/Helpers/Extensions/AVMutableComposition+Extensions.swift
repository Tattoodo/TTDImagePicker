import AVFoundation

// MARK: Trim

extension AVMutableComposition {
    convenience init(asset: AVAsset) {
        self.init()
        
        for track in asset.tracks {
            addMutableTrack(withMediaType: track.mediaType, preferredTrackID: track.trackID)
        }
    }
    
    func trim(timeOffStart: Double) {
        let duration = CMTime(seconds: timeOffStart, preferredTimescale: 1)
        let timeRange = CMTimeRange(start: CMTime.zero, duration: duration)
        
        for track in tracks {
            track.removeTimeRange(timeRange)
        }
        
        removeTimeRange(timeRange)
    }
}
