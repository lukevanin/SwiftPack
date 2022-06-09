import Foundation

@testable import CitySearch

struct MockTextIndex: TextIndex {
    
    var mockInsert: ((_ key: String, _ value: Int) -> Void)!
    var mockSearch: ((_ prefix: String) -> [Int])!
    
    func insert(key: String, value: Int) {
        mockInsert(key, value)
    }
    
    func search<S>(prefix: S) -> AnyIterator<Int> where S : StringProtocol {
        AnyIterator(mockSearch(String(prefix)).makeIterator())
    }
}
