import UIKit

enum TransitionDemoType {
    case hero
    case pinterest
    case banner
    
    var title: String {
        switch self {
        case .hero:
            "Hero Transition"
        case .pinterest:
            "Pinterest Transition"
        case .banner:
            "Banner Transition"
        }
    }
}
