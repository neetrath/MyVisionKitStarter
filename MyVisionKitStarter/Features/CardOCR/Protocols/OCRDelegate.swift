import UIKit

protocol OCRDelegate: AnyObject {
    func didReceive(cgImage: CGImage)
    func didError(_ error: OCRError)
}
