import XCTest

@testable import CitySearch

final class TextIndexDataCodableTests: XCTestCase {
    
    private var fileURL: URL!
    private var filePath: String!
    
    override func setUp() {
        let directoryURLs = FileManager.default.urls(
            for: .cachesDirectory,
               in: .userDomainMask
        )
        let filename = String(describing: TextIndexDataCodableTests.self) + UUID().uuidString
        fileURL = directoryURLs
            .first!
            .appendingPathComponent(filename, isDirectory: false)
            .appendingPathExtension("bin")
        filePath = fileURL.path
        print("Path:", filePath!)
    }
    
    func testDecodedSearch_shouldReturnData_givenZeroValues() throws {
        let trie = CaseInsensitiveTextIndex(TrieTextIndex<UInt32>())
        try trie.write(to: fileURL)
        
        let subject = try CaseInsensitiveTextIndex<TrieTextIndex<UInt32>>(fileURL: fileURL)
        let results = subject.search(prefix: "")
        XCTAssertEqual(Array(results.iterator), [])
    }
    
    func testDecodedSearch_shouldReturnData_givenOneCharacter() throws {
        var trie = CaseInsensitiveTextIndex(TrieTextIndex<UInt32>())
        trie.insert(key: "m", value: 13)
        try trie.write(to: fileURL)

        let subject = try CaseInsensitiveTextIndex<TrieTextIndex<UInt32>>(fileURL: fileURL)
        let results = subject.search(prefix: "m")
        XCTAssertEqual(Array(results.iterator), [13])
    }

    func testDecodedSearch_shouldReturnData_givenOneValue() throws {
        var trie = CaseInsensitiveTextIndex(TrieTextIndex<UInt32>())
        trie.insert(key: "foo", value: 13)
        try trie.write(to: fileURL)

        let subject = try CaseInsensitiveTextIndex<TrieTextIndex<UInt32>>(fileURL: fileURL)
        let results = subject.search(prefix: "foo")
        XCTAssertEqual(Array(results.iterator), [13])
    }
    
    func testDecodedSearch_shouldReturnData_givenSomeValues() throws {
        var trie = CaseInsensitiveTextIndex(TrieTextIndex<UInt32>())
        trie.insert(key: "foo", value: 11)
        trie.insert(key: "bar", value: 13)
        trie.insert(key: "baz", value: 17)
        try trie.write(to: fileURL)

        let subject = try CaseInsensitiveTextIndex<TrieTextIndex<UInt32>>(fileURL: fileURL)
        let results = subject.search(prefix: "b")
        XCTAssertEqual(Array(results.iterator), [13, 17])
    }
    
    func testJSONPerformance() throws {
        measure(metrics: defaultMetrics()) {
            let subject = try! loadCityData()
            XCTAssertEqual(Array(subject.search(prefix: "Witbank").iterator), [35999])
            XCTAssertEqual(Array(subject.search(prefix: "New York").iterator), [1340, 4818, 4846, 203003, 204085])
        }
    }

    func testDataCodecPerformance() throws {
        let index = try loadCityData()
        try index.write(to: fileURL)

        measure(metrics: defaultMetrics()) {
            let subject = try! CaseInsensitiveTextIndex<TrieTextIndex<UInt32>>(fileURL: fileURL)
            XCTAssertEqual(Array(subject.search(prefix: "Witbank").iterator), [35999])
            XCTAssertEqual(Array(subject.search(prefix: "New York").iterator), [1340, 4818, 4846, 203003, 204085])
        }
    }
    
//    func testInitPerformance_fromFile() throws {
//        let fileURL = Bundle.main.url(forResource: "cities.json", withExtension: "z")!
//
//        let subject = try CaseInsensitiveTextIndex<TrieTextIndex>(fileURL: fileURL)
//        XCTAssertEqual(Array(subject.search(prefix: "Witbank").iterator), [35999])
//        XCTAssertEqual(Array(subject.search(prefix: "New York").iterator), [1340, 4818, 4846, 203003, 204085])
//    }

    ///
    ///
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
