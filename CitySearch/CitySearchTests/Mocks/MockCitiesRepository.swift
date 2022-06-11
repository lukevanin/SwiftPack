import Foundation

@testable import CitySearch

final class MockCitiesRepository: CitiesRepositoryProtocol {
    
    var mockSearch: ((_ prefix: String) -> AnyCollection<City>)!
    
    func searchByName(prefix: String) async -> AnyCollection<City> {
        mockSearch(prefix)
    }
}
