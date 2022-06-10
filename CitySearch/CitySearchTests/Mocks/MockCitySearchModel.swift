import XCTest
import Combine

@testable import CitySearch

final class MockCitySearchModel: CitySearchModelProtocol {
    
    lazy var citiesPublisher = citiesSubject.compactMap({ $0 }).eraseToAnyPublisher()

    var citiesSubject = CurrentValueSubject<[City]?, Never>(nil)
    
    var mockSearchByName: ((_ prefix: String) -> Void)!
    
    func searchByName(prefix: String) {
        mockSearchByName(prefix)
    }
}
