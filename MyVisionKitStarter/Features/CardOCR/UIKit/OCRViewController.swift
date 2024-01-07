import AVFoundation
import UIKit
import Vision

class OCRViewController: UIViewController {
    // Video capture
    private let captureSession = AVCaptureSession()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    var captureDevice: AVCaptureDevice?

    // Video display layer
    lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    var maskLayer = CAShapeLayer()
    let citizenCardLayer = CAShapeLayer()
    let photoFrameLayer = CAShapeLayer()
    let circleLayer = CAShapeLayer()

    var configuration: OCRConfiguration = .init()
    var isAllowCapture = false
    weak var delegate: OCRDelegate?

    var manualCaptureButton: UIButton!

    private var cardCaptureState: OCRCaptureState = .notDetected {
        didSet {
            guard cardCaptureState != oldValue else {
                return
            }
            switch cardCaptureState {
            case .detected:
                citizenCardLayer.strokeColor = configuration.detectedBorderColor.cgColor
                citizenCardLayer.lineWidth = 4.0
                photoFrameLayer.strokeColor = configuration.detectedBorderColor.cgColor
                photoFrameLayer.lineWidth = 4.0
                circleLayer.strokeColor = configuration.detectedBorderColor.cgColor
                circleLayer.lineWidth = 4.0
            case .notDetected:
                citizenCardLayer.strokeColor = configuration.normalBorderColor.cgColor
                citizenCardLayer.lineWidth = 2.0
                photoFrameLayer.strokeColor = configuration.normalBorderColor.cgColor
                photoFrameLayer.lineWidth = 2.0
                circleLayer.strokeColor = configuration.normalBorderColor.cgColor
                circleLayer.lineWidth = 2.0
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCamera()
        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        videoDataOutput.setSampleBufferDelegate(nil, queue: nil)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.frame
    }

    func setup(configuration: OCRConfiguration) {
        self.configuration = configuration
    }

    private func setupCamera() {
        setCameraInput()
        showCameraFeed()
        setCameraOutput()

        addRectangleOverlay()
    }

    private func setupView() {
        // Set up the capture button
        let buttonSize: CGFloat = configuration.buttonSize
        manualCaptureButton = UIButton()
        manualCaptureButton.translatesAutoresizingMaskIntoConstraints = false
        manualCaptureButton.layer.cornerRadius = buttonSize / 2
        manualCaptureButton.clipsToBounds = true
        manualCaptureButton.setBackgroundColor(color: .white, forState: .normal)
        manualCaptureButton.setBackgroundColor(color: .white.withAlphaComponent(0.5), forState: .highlighted)
        manualCaptureButton.addTarget(self, action: #selector(doScan), for: .touchUpInside)
        manualCaptureButton.isHidden = false
        view.addSubview(manualCaptureButton)

        manualCaptureButton.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        manualCaptureButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        manualCaptureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        manualCaptureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true

        // Set up the label
        let rectangleOrigin = CGPoint(x: 32, y: 192)
        let labelLeadingSpace: CGFloat = 32
        let labelTrailingSpace: CGFloat = 32
        let labelOriginY = rectangleOrigin.y + 32

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = configuration.labelText
        label.textAlignment = .center
        label.textColor = configuration.labelTextColor
        label.font = configuration.labelFont
        label.numberOfLines = 0
        view.addSubview(label)

        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: labelLeadingSpace).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -labelTrailingSpace).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: labelOriginY).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    @objc func doScan(sender: UIButton!) {
        isAllowCapture = true
    }

    private func setCameraInput() {
        guard let device = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
            mediaType: .video,
            position: .back).devices.first else {
            print("No back camera device found.")
            #if targetEnvironment(simulator)
                delegate?.didReceive(cgImage: UIImage(named: "fake_citizen_card")!.cgImage!)
            #else
                delegate?.didError(.noCameraInput)
            #endif
            return
        }
        captureDevice = device
        do {
            let cameraInput = try AVCaptureDeviceInput(device: device)
            captureSession.addInput(cameraInput)
        } catch {
            delegate?.didError(.noCameraInput)
        }
    }

    private func showCameraFeed() {
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
    }

    private func setCameraOutput() {
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as NSString: NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]

        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        captureSession.addOutput(videoDataOutput)

        guard let connection = videoDataOutput.connection(with: AVMediaType.video),
              connection.isVideoRotationAngleSupported(0.0) else {
            delegate?.didError(.noCameraOutput)
            return
        }

        connection.videoRotationAngle = 0.0
    }

    private func doPerspectiveCorrection(_ observation: VNRectangleObservation, from buffer: CVImageBuffer) {
        var ciImage = CIImage(cvImageBuffer: buffer)

        let topLeft = observation.topLeft.scaled(to: ciImage.extent.size)
        let topRight = observation.topRight.scaled(to: ciImage.extent.size)
        let bottomLeft = observation.bottomLeft.scaled(to: ciImage.extent.size)
        let bottomRight = observation.bottomRight.scaled(to: ciImage.extent.size)

        // Calculate extra area outside the corners
        let extraArea: CGFloat = 20.0
        let topLeftWithMargin = CGPoint(x: topLeft.x - extraArea, y: topLeft.y + extraArea)
        let topRightWithMargin = CGPoint(x: topRight.x + extraArea, y: topRight.y + extraArea)
        let bottomLeftWithMargin = CGPoint(x: bottomLeft.x - extraArea, y: bottomLeft.y - extraArea)
        let bottomRightWithMargin = CGPoint(x: bottomRight.x + extraArea, y: bottomRight.y - extraArea)

        // Pass those to the filter to extract/rectify the image
        ciImage = ciImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: topLeftWithMargin),
            "inputTopRight": CIVector(cgPoint: topRightWithMargin),
            "inputBottomLeft": CIVector(cgPoint: bottomLeftWithMargin),
            "inputBottomRight": CIVector(cgPoint: bottomRightWithMargin),
        ])

        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            delegate?.didReceive(cgImage: cgImage)
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension OCRViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("unable to get image from sample buffer")
            return
        }
        detectRectangle(in: frame)
    }
}

// MARK: - Dynamic overlay

extension OCRViewController {
    private func detectRectangle(in image: CVPixelBuffer) {
        let request = VNDetectRectanglesRequest(completionHandler: { (request: VNRequest, _: Error?) in
            DispatchQueue.main.async {
                guard let results = request.results as? [VNRectangleObservation],
                      let rect = results.first
                else {
                    self.cardCaptureState = .notDetected
                    return
                }

                if rect.confidence > self.configuration.minimumConfidence {
                    self.cardCaptureState = .detected
                    if self.isAllowCapture {
                        self.isAllowCapture = false
                        self.doPerspectiveCorrection(rect, from: image)
                    }
                } else {
                    self.cardCaptureState = .notDetected
                }
            }
        })

        request.minimumAspectRatio = VNAspectRatio(1.3) // This is the ratio of the card. Don't change it.
        request.maximumAspectRatio = VNAspectRatio(1.6) // This is the ratio of the card. Don't change it.
        request.quadratureTolerance = configuration.quadratureTolerance
        request.minimumSize = configuration.minimumSize
        request.minimumConfidence = configuration.minimumConfidence
        request.maximumObservations = configuration.maximumObservations

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
        try? imageRequestHandler.perform([request])
    }
}
