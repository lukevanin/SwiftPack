import Foundation

@testable import CitySearch

final class MockCitiesRepository: CitiesRepositoryProtocol {
    
    var mockSearch: ((_ prefix: String) -> AnySequence<City>)!
    
    func searchByName(prefix: String) async -> AnySequence<City> {
        mockSearch(prefix)
    }
}
