import UIKit

extension CGPoint {
    func scaled(to size: CGSize) -> CGPoint {
        return CGPoint(x: x * size.width, y: y * size.height)
    }
}
