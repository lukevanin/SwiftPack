import UIKit

final class NavigationCoordinator: PresentingCoordinatorProtocol {
    
    weak var context: UIViewController?
    
    func present(viewController: UIViewController) async {
        await withCheckedContinuation { continuation in
            context?.present(viewController, animated: true) {
                continuation.resume()
            }
        }
    }
}
