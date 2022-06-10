import XCTest
import Combine

@testable import CitySearch

///
/// City search model tests.
///
/// Tests the behaviour of the city search model. Much of the capability of the `CitySearchModel`
/// is handled by its cities repository. We can assume the repository is tested and works as intended, and
/// only need to test the behaviour of the model itself, which amounts to executing search requests
/// asynchronously.
///
final class CitySearchModelTests: XCTestCase {
    
    private var mockRepository: MockCitiesRepository!
    private var subject: CitySearchModel!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        mockRepository = MockCitiesRepository()
        subject = CitySearchModel(citiesRepository: mockRepository)
        cancellables = Set()
    }
    
    override func tearDown() {
        mockRepository = nil
        subject = nil
        cancellables = nil
    }
    
    #warning("TODO: Test that search query is case-insensitive")
    
    func testSearch_shouldReturnNothing_givenNonMatchingPrefix() {
        mockRepository.mockSearch = { query in
            XCTAssertEqual(query, "foo")
            return AnySequence([])
        }
        
        subject.searchByName(prefix: "foo")
        
        let expectation = expectation(description: "result")
        subject.citiesPublisher
            .sink { cities in
                XCTAssertEqual(cities, [])
                expectation.fulfill()
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 0.1)
    }

    func testSearch_shouldReturnCities_givenMatchingPrefix() {
        let city = City.wellingtonZA()
        mockRepository.mockSearch = { query in
            XCTAssertEqual(query, "foo")
            return AnySequence([city])
        }
        
        subject.searchByName(prefix: "foo")
        
        let expectation = expectation(description: "result")
        subject.citiesPublisher
            .sink { cities in
                XCTAssertEqual(cities, [city])
                expectation.fulfill()
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 0.1)
    }
}
