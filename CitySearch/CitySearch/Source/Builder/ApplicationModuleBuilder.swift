import UIKit

struct ApplicationModuleBuilder: BuilderProtocol {
    
    let environment: Environment
    
    func build() -> UIViewController {
        let moduleBuilder = SearchModuleBuilder(environment: environment)
        let initialViewController = moduleBuilder.build()
        let navigationController = UINavigationController(
            rootViewController: initialViewController
        )
        navigationController.navigationBar.barTintColor = .red
        return navigationController
    }
}
