import UIKit

///
/// Constructs a search view controller with predefined data for testing purpose.
///
struct TestSearchModuleBuilder: BuilderProtocol {
    
    var environment: Environment

    func build() -> UIViewController {
        let cities = TestCitiesBuilder().build()
        var searchIndex = TrieTextIndex()
        cities.enumerated().forEach { index, city in
            let key = city.name.lowercased()
            searchIndex.insert(key: key, value: index)
        }
        let searchRepository = IndexedCitiesRepository(cities: cities, nameIndex: searchIndex)
        let searchModel = CitySearchModel(citiesRepository: searchRepository)
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
