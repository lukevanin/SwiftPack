import UIKit

struct ApplicationCoordinatorBuilder: BuilderProtocol {
    
    let windowScene: UIWindowScene
    
    func build() -> ActivatingCoordinatorProtocol {
        let searchCoordinator = CitySearchCoordinator()
        let environment = Environment()
        environment.searchDelegate = searchCoordinator
        let moduleBuilder = ApplicationModuleBuilder(environment: environment)
        let viewController = moduleBuilder.build()
        let navigationCoordinator = NavigationCoordinator()
        navigationCoordinator.context = viewController
        navigationCoordinator.add(child: searchCoordinator)
        let windowCoordinator = WindowCoordinator()
        windowCoordinator.windowScene = windowScene
        windowCoordinator.viewController = viewController
        windowCoordinator.add(child: navigationCoordinator)
        return windowCoordinator
    }
}
