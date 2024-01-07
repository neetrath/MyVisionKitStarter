import UIKit

extension OCRViewController {
    func addRectangleOverlay() {
        let padding = 24.0
        let topSpacing = 192.0
        let citizenCardFrameWidth = previewLayer.bounds.width - (padding * 2)
        let citizenCardFrameHeight = citizenCardFrameWidth * 0.628
        let citizenCardFrameSize = CGSize(width: citizenCardFrameWidth, height: citizenCardFrameHeight)
        let citizenCardFrameOrigin = CGPoint(x: padding, y: topSpacing)
        let citizenCardFramePath = UIBezierPath(roundedRect: CGRect(origin: citizenCardFrameOrigin, size: citizenCardFrameSize), cornerRadius: 10)

        let outerPath = UIBezierPath(rect: previewLayer.bounds)
        outerPath.append(citizenCardFramePath)
        outerPath.usesEvenOddFillRule = true

        // Draw a background overlay
        let fillLayer = CAShapeLayer()
        fillLayer.path = outerPath.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = configuration.fillColor.cgColor
        fillLayer.opacity = 0.8
        previewLayer.addSublayer(fillLayer)

        // Draw a citizen card frame overlay.
        citizenCardLayer.path = citizenCardFramePath.cgPath
        citizenCardLayer.strokeColor = configuration.normalBorderColor.cgColor
        citizenCardLayer.fillColor = UIColor.clear.cgColor
        citizenCardLayer.lineWidth = 2
        previewLayer.addSublayer(citizenCardLayer)

        // Draw a rectangle photo frame overlay at the bottom right.
        let photoFrameWidth = 67.0
        let photoFrameHeight = 87.0

        let photoFrameSize = CGSize(width: photoFrameWidth, height: photoFrameHeight)
        let photoFrameOrigin = CGPoint(x: padding + citizenCardFrameWidth - photoFrameWidth - 16,
                                       y: topSpacing + citizenCardFrameHeight - photoFrameHeight - 16)
        let photoFramePath = UIBezierPath(rect: CGRect(origin: photoFrameOrigin, size: photoFrameSize))

        photoFrameLayer.path = photoFramePath.cgPath
        photoFrameLayer.fillColor = UIColor.clear.cgColor
        photoFrameLayer.strokeColor = UIColor.white.cgColor
        photoFrameLayer.lineWidth = 2.0
        previewLayer.addSublayer(photoFrameLayer)

        // Draw a circle overlay at the top right.
        let circleHeight = 40.0
        let circleSize = CGSize(width: circleHeight, height: circleHeight)
        let circleOrigin = CGPoint(x: padding + 2, y: topSpacing + 4)
        let circlePath = UIBezierPath(roundedRect: CGRect(origin: circleOrigin, size: circleSize), cornerRadius: circleHeight / 2)

        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.white.cgColor
        circleLayer.lineWidth = 2.0
        previewLayer.addSublayer(circleLayer)
    }
}
