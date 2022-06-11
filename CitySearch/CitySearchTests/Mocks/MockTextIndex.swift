import Foundation

@testable import CitySearch

struct MockTextIndex: TextIndex {
    
    var mockInsert: ((_ key: String, _ value: Int) -> Void)!
    var mockSearch: ((_ prefix: String) -> [Int])!
    
    func insert(key: String, value: Int) {
        mockInsert(key, value)
    }
    
    func search<S>(prefix: S) -> TextIndexSearchResult where S : StringProtocol {
        let result = mockSearch(String(prefix))
        return TextIndexSearchResult(
            count: result.count,
            iterator: AnyIterator(result.makeIterator())
        )
    }
}
