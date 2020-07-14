import AVFoundation

extension AVCaptureDevice {
    func tryToggleTorch() {
        guard hasFlash else { return }
        do {
            try lockForConfiguration()
            switch torchMode {
            case .auto:
                torchMode = .on
            case .on:
                torchMode = .off
            case .off:
                torchMode = .auto
            @unknown default:
                fatalError()
            }
            unlockForConfiguration()
        } catch _ { }
    }
}
