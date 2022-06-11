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
        cancellables.forEach { $0.cancel() }
        cancellables = nil
    }
    
    #warning("TODO: Test that search query is case-insensitive")
    
    func testSearch_shouldReturnNil_givenEmptyPrefix() async throws {
        let searchNotExpected = expectation(description: "search")
        searchNotExpected.isInverted = true
        mockRepository.mockSearch = { query in
            XCTAssertEqual(query, "")
            searchNotExpected.fulfill()
            return AnyCollection([])
        }
        
        subject.searchByName(prefix: "")
        
        wait(for: [searchNotExpected], timeout: 0.1)
        try await Task.sleep(seconds: 0.1)
        await verifyCities(nil)
    }

    func testSearch_shouldReturnEmpty_givenNonMatchingPrefix() async throws {
        mockRepository.mockSearch = { query in
            XCTAssertEqual(query, "foo")
            return AnyCollection([])
        }
        
        subject.searchByName(prefix: "foo")
        try await Task.sleep(seconds: 0.1)
        await verifyCities([])
   }

    func testSearch_shouldReturnCities_givenMatchingPrefix() async throws {
        let city = City.wellingtonZA()
        mockRepository.mockSearch = { query in
            XCTAssertEqual(query, "foo")
            return AnyCollection([city])
        }
        subject.searchByName(prefix: "foo")
        try await Task.sleep(seconds: 0.1)
        await verifyCities([city])
    }
    
    // MARK: Helpers
    
    private func verifyCities(_ cities: [City]?, file: StaticString = #file, line: UInt = #line) async {
        var values = subject
            .citiesPublisher
            .map { collection in
                collection.flatMap { collection in
                    Array(collection)
                }
            }
            .values
            .makeAsyncIterator()
        let results = await values.next()
        XCTAssertEqual(results, cities, file: file, line: line)
    }
}
