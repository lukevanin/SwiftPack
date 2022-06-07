import Foundation

///
/// A hash table where keys are strings and values are integers.
///
/// A collection that stores values associated with a unique key. A query string is provided to return a subset of
/// the stored values. The index returns values where the prefix of the key matches the given query.
///
/// The prefix is defined as the substring of the key, from the beginning of the key, and of the same length
/// as the query.
///
/// The index is usually used to implement text search capabilities for a data set containing complex
/// objects. The text index would contain keys with the text that can be searched, with the val ues referring
/// to an index of the data to return.
///
/// Behaviours:
/// - An empty query returns a collection containing all of the values contained within the tree.
/// - A non-empty query returns a collection containing all of the values whose key prefix matches the query.
/// - If no keys match the given query, then an empty collection is returned.
///
protocol TextIndex {
    
    ///
    /// Inserts a value with a given key index to the index, and returns a value with a given key if one exists.
    ///
    /// - Parameter key: The key associated with the value.
    /// - Returns: The value associated with the key, if one exists.
    ///
    subscript(_ key: String) -> Int? { get set }
    
    ///
    /// Retrieves all values whose key starts with the given query.
    ///
    /// - Parameter prefix: String to search for. The prefix may be any object that conforms to the
    /// StringProtocol.
    /// - Returns: A collecion of values whose keys start with the given prefix. Values are returned
    /// sorted relative to the alphabetical order of their keys.
    ///
    mutating func search<S>(prefix: S) -> [Int] where S: StringProtocol
}

///
/// A text index that is implemented using linear search to locate elements.
///
/// A collection of key-value pairs. Queries are fulfilled using a simple but inefficient linear search algorithm.
/// That is, each key is matched against the query.
///
/// - Note: This index should not be used in real world applications. It exists as a worst case baseline
/// comparison for more efficient implementations which should be used instead.
///
struct LinearTextIndex: TextIndex {
    
    private var keyValues = [(key: String, value: Int)]()
    
    subscript(key: String) -> Int? {
        get {
            return nil
        }
        set {
            
        }
    }
    
    func search<S>(prefix: S) -> [Int] where S : StringProtocol {
        return []
    }
}
