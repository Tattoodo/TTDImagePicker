import AVFoundation

extension AVCaptureSession {
    func resetInputs() {
        // remove all sesison inputs
        for i in inputs {
            removeInput(i)
        }
    }
}
