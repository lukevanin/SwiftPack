import UIKit
import OSLog

private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: "window-coordinator"
)

final class WindowCoordinator: AnyCoordinator, ActivatingCoordinatorProtocol {

    weak var windowScene: UIWindowScene?
    var viewController: UIViewController?

    private var window: UIWindow?
    
    // MARK: ActivatingCoordinatorProtocol
    
    func activate() {
        guard let windowScene = windowScene else {
            logger.warning("Cannot instantiate window. Missing window scene.")
            return
        }
        guard let viewController = viewController else {
            logger.warning("Cannot instantiate window. Missing view controller.")
            return
        }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
}
