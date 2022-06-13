import UIKit

struct ApplicationCoordinatorBuilder: BuilderProtocol {
    
    let windowScene: UIWindowScene
    
    func build() throws -> ActivatingCoordinatorProtocol {
        let searchCoordinator = CitySearchCoordinator()
        #warning("TODO: Refactor environment constructor into its own builder")
        let environment = Environment(
            citiesRepository: try makeCitiesRepository(),
            searchDelegate: searchCoordinator
        )
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
    
    private func makeCitiesRepository() throws -> CitiesRepositoryProtocol {
        #warning("TODO: Refactor repository construction into separate builders")
        let arguments = ProcessInfo.processInfo.arguments
        let repository: CitiesRepositoryProtocol
        if arguments.contains("test") {
            // We are running under developmenu or automated or testing
            // conditions. Use the testing module.
            let builder = TestCitiesRepositoryBuilder(
                makeKey: makeKey
            )
            repository = builder.build()
        }
        else {
            // Use the production module.
//            let fileURL = Bundle.main.url(
//                forResource: "cities",
//                withExtension: "json"
//            )!
//            let data = try Data(contentsOf: fileURL)
//            let builder = JSONCitiesRepositoryBuilder(
//                data: data,
//                makeKey: makeKey
//            )
//            repository = try builder.build()
            let fileURL = Bundle.main.url(
                forResource: "cities-repository",
                withExtension: "z"
            )!
            repository = try IndexedCitiesRepository<CaseInsensitiveTextIndex<TrieTextIndex<UInt32>>>(
                fileURL: fileURL
            )
        }
        return repository
    }
    
    private func makeKey(city: City) -> String {
        return city.name
    }
}
