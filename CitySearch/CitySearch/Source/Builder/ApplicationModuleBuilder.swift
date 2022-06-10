import UIKit

struct ApplicationModuleBuilder: BuilderProtocol {
    
    func build() -> UIViewController {
        let coordinator = NavigationCoordinator()
        let rootViewController = makeRootViewController(coordinator: coordinator)
        let navigationController = UINavigationController(
            rootViewController: rootViewController
        )
        coordinator.context = navigationController
        navigationController.view.tintColor = .systemRed
        return navigationController
    }
    
    private func makeRootViewController(coordinator: PresentingCoordinatorProtocol) -> UIViewController {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("test") {
            // We are running under developmenu or automated or testing
            // conditions. Use the testing module.
            let builder = TestSearchModuleBuilder(
                parentCoordinator: coordinator
            )
            return builder.build()
        }
        else {
            // Use the production module.
            let builder = SearchModuleBuilder(
                parentCoordinator: coordinator
            )
            return builder.build()
        }
    }
}
