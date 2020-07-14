import AVFoundation

extension AVPlayer {
    func togglePlayPause(completion: (_ isPlaying: Bool) -> Void) {
        if rate == 0 {
            play()
            completion(true)
        } else {
            pause()
            completion(false)
        }
    }
}
