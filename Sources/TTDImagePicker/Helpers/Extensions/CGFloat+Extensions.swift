import UIKit

infix operator &/

// With that you can devide to zero
extension CGFloat {
    public static func &/ (lhs: CGFloat, rhs: CGFloat) -> CGFloat {
        if rhs == 0 {
            return 0
        }
        return lhs/rhs
    }
}
