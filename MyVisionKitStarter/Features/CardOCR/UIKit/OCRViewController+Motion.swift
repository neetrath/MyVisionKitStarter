import CoreMotion

extension OCRViewController {
    func turnOnAutoCapture() {
        manualCaptureButton.isHidden = true
        startAccelerometerUpdates()
    }

    func turnOffAutoCapture() {
        manualCaptureButton.isHidden = false
        stopAccelerometerUpdates()
    }

    func startStableTimer() {
        stableTimer?.invalidate()
        stableTimer = Timer.scheduledTimer(withTimeInterval: stableTime, repeats: false) { [weak self] _ in
            self?.handleStableTimerFired()
        }
    }

    func resetStableTimer() {
        stableTimer?.invalidate()
        stableTimer = nil
    }

    private func handleStableTimerFired() {
        print("Device is stable")
        isStopShaking = true
    }

    private func detectShaking(_ data: CMAccelerometerData) {
        let acceleration = data.acceleration
        let accelerationMagnitude = sqrt(pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2))
        let deviation = abs(accelerationMagnitude - 1)
        isShaking = deviation > shakingThreshold
    }

    private func startAccelerometerUpdates() {
        guard coreMotionManager.isAccelerometerAvailable else {
            // Accelerometer is not available, handle accordingly
            return
        }

        coreMotionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] data, _ in
            guard let accelerometerData = data else {
                // Handle error
                return
            }

            self?.detectShaking(accelerometerData)
        }
    }

    func stopAccelerometerUpdates() {
        coreMotionManager.stopAccelerometerUpdates()
        resetStableTimer()
    }
}
