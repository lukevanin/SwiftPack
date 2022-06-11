import UIKit

///
/// Constructs a view controller, and required dependencies, for providing search capabilities using real data/
///
struct SearchModuleBuilder: BuilderProtocol {
    
    var environment: Environment
    
    func build() -> UIViewController {
        let searchModel = CitySearchModel(
            citiesRepository: environment.citiesRepository
        )
        let viewController = SearchViewController(
            model: searchModel,
            makeCellConfiguration: { city in
                CitySearchResultCellContentBuilder(city: city).build()
            }
        )
        viewController.delegate = environment.searchDelegate
        return viewController
    }
}
