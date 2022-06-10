import UIKit

///
/// Constructs a view controller, and required dependencies, for providing search capabilities using real data/
///
final class SearchModuleBuilder: BuilderProtocol {
    
    func build() -> UIViewController {
        let searchIndex = TrieTextIndex()
        let searchRepository = IndexedCitiesRepository(cities: [], nameIndex: searchIndex)
        let searchModel = CitySearchModel(citiesRepository: searchRepository)
        let viewController = SearchViewController(
            model: searchModel,
            makeCellConfiguration: { cell in
                SearchResultViewContentConfiguration(
                    title: cell.name,
                    subtitle: ""
                )
            }
        )
        return viewController
    }
}
