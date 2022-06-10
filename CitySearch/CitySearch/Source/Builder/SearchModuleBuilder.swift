import UIKit

///
/// Constructs a view controller, and required dependencies, for providing search capabilities using real data/
///
struct SearchModuleBuilder: BuilderProtocol {
    
    func build() -> UIViewController {
        let searchIndex = TrieTextIndex()
        let searchRepository = IndexedCitiesRepository(cities: [], nameIndex: searchIndex)
        let searchModel = CitySearchModel(citiesRepository: searchRepository)
        let viewController = SearchViewController(
            model: searchModel,
            makeCellConfiguration: { city in
                CitySearchResultCellContentBuilder(city: city).build()
            }
        )
        return viewController
    }
}
