import UIKit

struct ApplicationModuleBuilder: BuilderProtocol {
    
    let environment: Environment
    
    func build() -> UIViewController {
        let initialViewController = makeRootViewController()
        let navigationController = UINavigationController(
            rootViewController: initialViewController
        )
        navigationController.navigationBar.barTintColor = .red
        return navigationController
    }
    
    private func makeRootViewController() -> UIViewController {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("test") {
            // We are running under developmenu or automated or testing
            // conditions. Use the testing module.
            let builder = TestSearchModuleBuilder(environment: environment)
            return builder.build()
        }
        else {
            // Use the production module.
            let builder = SearchModuleBuilder(environment: environment)
            return builder.build()
        }
    }
}
