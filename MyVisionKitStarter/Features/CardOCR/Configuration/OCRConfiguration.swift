import UIKit
import Vision

struct OCRConfiguration {
    let normalBorderColor: UIColor
    let partialDetectedBorderColor: UIColor
    let detectedBorderColor: UIColor
    let fillColor: UIColor

    let labelFont: UIFont?
    let labelTextColor: UIColor
    let labelText: String

    let buttonSize: CGFloat

    let quadratureTolerance: VNDegrees
    let minimumSize: Float
    let minimumConfidence: VNConfidence
    let maximumObservations: Int

    init(normalBorderColor: UIColor = .white,
         partialDetectedBorderColor: UIColor = .yellow,
         detectedBorderColor: UIColor = .green,
         fillColor: UIColor = .gray,
         labelFont: UIFont? = UIFont.systemFont(ofSize: 14),
         labelTextColor: UIColor = .white,
         labelText: String = "ID Card capture",
         buttonSize: CGFloat = 64.0,
         quadratureTolerance: VNDegrees = VNDegrees(5),
         minimumSize: Float = 0.4,
         minimumConfidence: VNConfidence = VNConfidence(0.9),
         maximumObservations: Int = 1) {
        
        self.normalBorderColor = normalBorderColor
        self.partialDetectedBorderColor = partialDetectedBorderColor
        self.detectedBorderColor = detectedBorderColor
        self.fillColor = fillColor

        self.labelFont = labelFont
        self.labelTextColor = labelTextColor
        self.labelText = labelText

        self.buttonSize = buttonSize

        self.quadratureTolerance = quadratureTolerance
        self.minimumSize = minimumSize
        self.minimumConfidence = minimumConfidence
        self.maximumObservations = maximumObservations
    }
}
