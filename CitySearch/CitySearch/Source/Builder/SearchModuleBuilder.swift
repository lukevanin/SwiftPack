import UIKit

///
/// Constructs a view controller, and required dependencies, for providing search capabilities using real data/
///
struct SearchModuleBuilder: BuilderProtocol {
    
    var parentCoordinator: PresentingCoordinatorProtocol
    
    func build() -> UIViewController {
        let searchIndex = TrieTextIndex()
        let searchRepository = IndexedCitiesRepository(cities: [], nameIndex: searchIndex)
        let searchModel = CitySearchModel(citiesRepository: searchRepository)
        let viewController = SearchViewController(
            model: searchModel,
            makeCellConfiguration: { city in
                CitySearchResultCellContentBuilder(city: city).build()
            },
            selectCell: { city in
                Task {
                    let coordinator = BuilderPresentingCoordinator(
                        builder: AnyBuilder(MapModuleBuilder(city: city))
                    )
                    coordinator.parent = parentCoordinator
                    try await coordinator.activate()
                }
            }
        )
        return viewController
    }
}
