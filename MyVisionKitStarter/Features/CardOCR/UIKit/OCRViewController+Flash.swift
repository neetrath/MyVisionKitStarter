import AVFoundation

extension OCRViewController {
    func turnOnTorch() {
        guard let device = captureDevice, device.hasTorch else { return }
        withDeviceLock(on: device) {
            try? $0.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
        }
    }

    func turnOffTorch() {
        guard let device = captureDevice, device.hasTorch else { return }
        withDeviceLock(on: device) {
            $0.torchMode = .off
        }
    }

    private func withDeviceLock(on device: AVCaptureDevice, block: (AVCaptureDevice) -> Void) {
        do {
            try device.lockForConfiguration()
            block(device)
            device.unlockForConfiguration()
        } catch {
            print("Cannot acquire device lock")
        }
    }
}
