import UIKit

final class NavigationCoordinator: AnyCoordinator {
    
    weak var context: UIViewController?

    override func present(viewController: UIViewController) async {
        let navigationController = (context as? UINavigationController) ?? context?.navigationController
        navigationController?.pushViewController(viewController, animated: true)
        #warning("TODO: Wait for navigation animation to finish")
    }
}
