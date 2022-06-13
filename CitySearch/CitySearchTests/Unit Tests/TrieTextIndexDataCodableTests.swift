import XCTest

@testable import CitySearch

final class TrieTextIndexDataCodableTests: XCTestCase {
    
    func testDecodedSearch_shouldReturnData_givenZeroValues() throws {
        let surrogate = CaseInsensitiveTextIndex(TrieTextIndex<UInt32>())
        let data = surrogate.data()
        let subject = try CaseInsensitiveTextIndex<TrieTextIndex<UInt32>>(data: data)
        let results = subject.search(prefix: "")
        XCTAssertEqual(Array(results.iterator), [])
    }
    
    func testDecodedSearch_shouldReturnData_givenOneCharacter() throws {
        var surrogate = CaseInsensitiveTextIndex(TrieTextIndex<UInt32>())
        surrogate.insert(key: "m", value: 13)
        let data = surrogate.data()
        let subject = try CaseInsensitiveTextIndex<TrieTextIndex<UInt32>>(data: data)
        let results = subject.search(prefix: "m")
        XCTAssertEqual(Array(results.iterator), [13])
    }

    func testDecodedSearch_shouldReturnData_givenOneValue() throws {
        var surrogate = CaseInsensitiveTextIndex(TrieTextIndex<UInt32>())
        surrogate.insert(key: "foo", value: 13)
        let data = surrogate.data()
        let subject = try CaseInsensitiveTextIndex<TrieTextIndex<UInt32>>(data: data)
        let results = subject.search(prefix: "foo")
        XCTAssertEqual(Array(results.iterator), [13])
    }
    
    func testDecodedSearch_shouldReturnData_givenSomeValues() throws {
        var surrogate = CaseInsensitiveTextIndex(TrieTextIndex<UInt32>())
        surrogate.insert(key: "foo", value: 11)
        surrogate.insert(key: "bar", value: 13)
        surrogate.insert(key: "baz", value: 17)
        let data = surrogate.data()
        let subject = try CaseInsensitiveTextIndex<TrieTextIndex<UInt32>>(data: data)
        let results = subject.search(prefix: "b")
        XCTAssertEqual(Array(results.iterator), [13, 17])
    }
    
    func testEncodeDecodeConsistency() throws {
        var surrogate = CaseInsensitiveTextIndex(TrieTextIndex<UInt32>())
        surrogate.insert(key: "foo", value: 11)
        surrogate.insert(key: "bar", value: 13)
        surrogate.insert(key: "baz", value: 17)
        let data = surrogate.data()
        let subject = try CaseInsensitiveTextIndex<TrieTextIndex<UInt32>>(data: data)
        XCTAssertEqual(surrogate, subject)
    }

    func testJSONEncodeDecodeConsistency() throws {
        let surrogate = try! loadCityData()
        let data = surrogate.data()
        let subject = try CaseInsensitiveTextIndex<TrieTextIndex<UInt32>>(data: data)
        XCTAssertEqual(surrogate, subject)
    }

    ///
    /// Loads the cities from the orignal JSON data set.
    ///
    private func loadCityData() throws -> CaseInsensitiveTextIndex<TrieTextIndex<UInt32>> {
        let url = Bundle.main.url(forResource: "cities", withExtension: "json")!
        let data = try Data(contentsOf: url, options: [.uncached])
        let decoder = JSONDecoder()
        let cities = try decoder.decode([City].self, from: data)
        var nameIndex = CaseInsensitiveTextIndex(TrieTextIndex<UInt32>())
        cities.enumerated().forEach { index, city in
            nameIndex.insert(key: city.name, value: UInt32(index))
        }
        return nameIndex
    }
    
}
