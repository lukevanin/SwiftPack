import XCTest
import Combine

@testable import CitySearch

final class MockCitySearchModel: CitySearchModelProtocol {
    
    lazy var citiesPublisher = citiesSubject.eraseToAnyPublisher()

    var citiesSubject = CurrentValueSubject<[City], Never>([])
    
    var mockSearchByName: ((_ prefix: String) -> Void)!
    
    func searchByName(prefix: String) {
        mockSearchByName(prefix)
    }
}
