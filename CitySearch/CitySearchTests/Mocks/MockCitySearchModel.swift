import XCTest
import Combine

@testable import CitySearch

final class MockCitySearchModel: CitySearchModelProtocol {
    
    lazy var citiesPublisher: AnyPublisher<AnyCollection<City>?, Never> = citiesSubject
        .map { cities in
            cities.map { cities in
                AnyCollection(cities)
            }
        }
        .eraseToAnyPublisher()

    var citiesSubject = CurrentValueSubject<[City]?, Never>(nil)
    
    var mockSearchByName: ((_ prefix: String) -> Void)!
    
    func searchByName(prefix: String) {
        mockSearchByName(prefix)
    }
}
