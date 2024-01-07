import SwiftUI

struct CardOCRWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = OCRViewController

    var configuration: OCRConfiguration
    var delegate: OCRDelegate

    @Binding var isFlashOn: Bool
    @Binding var isAutoCapture: Bool

    func makeUIViewController(context: Context) -> OCRViewController {
        let viewController = OCRViewController()
        viewController.delegate = delegate
        viewController.setup(configuration: configuration)
        return viewController
    }

    func updateUIViewController(_ uiViewController: OCRViewController, context: Context) {
        if isFlashOn {
            uiViewController.turnOnTorch()
        } else {
            uiViewController.turnOffTorch()
        }

        if isAutoCapture {
            uiViewController.turnOnAutoCapture()
        } else {
            uiViewController.turnOffAutoCapture()
        }
    }
}
