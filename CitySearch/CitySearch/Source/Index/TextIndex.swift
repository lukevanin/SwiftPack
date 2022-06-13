import Foundation


///
/// A result from a `TextIndex` search.
///
/// Contains the number of items returned from the result, and an iterator for accessing the result values.
///
struct TextIndexSearchResult<Value> {
    let count: Int
    var iterator: AnyIterator<Value>
}


///
/// A collection where keys are strings and values are integers.
///
/// A collection that stores integers associated with a string. Values can be retrieved using a query string,
/// where values whose prefix matches the provided query
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
    /// Type of the values stored in the index.
    ///
    associatedtype Value
    
    ///
    /// Inserts a value into the index associated with a key string.
    ///
    mutating func insert(key: String, value: Value)
    
    ///
    /// Retrieves all values whose key starts with the given query.
    ///
    /// - Parameter prefix: String to search for. The prefix may be any object that conforms to the
    /// StringProtocol.
    /// - Returns: A collecion of values whose keys start with the given prefix. Values are returned
    /// sorted relative to the alphabetical order of their keys.
    ///
    func search<S>(prefix: S) -> TextIndexSearchResult<Value> where S: StringProtocol
}


///
/// Type-erased text index.
///
/// Erases the specific type of a text index. Used to pass text index instances generically.
///
struct AnyTextIndex<Value>: TextIndex {
        
    private let wrapper: _TextIndex<Value>

    init<Index>(_ index: Index) where Index: TextIndex, Index.Value == Value {
        self.wrapper = _TextIndexWrapper(index)
    }
    
    mutating func insert(key: String, value: Value) {
        #warning("TODO: Implement copy-on-write for wrapped value")
        wrapper.insert(key: key, value: value)
    }
    
    func search<S>(prefix: S) -> TextIndexSearchResult<Value> where S : StringProtocol {
        wrapper.search(prefix: prefix)
    }
}


///
/// Type-erased text index.
///
/// Erases the specific type of a text index. Used to pass text index instances generically.
///
private class _TextIndex<Value>: TextIndex {
    
    fileprivate init() {
        
    }
    
    func insert(key: String, value: Value) {
        fatalError("not implemented")
    }
    
    func search<S>(prefix: S) -> TextIndexSearchResult<Value> where S : StringProtocol {
        fatalError("not implemented")
    }
}


///
///
///
final private class _TextIndexWrapper<Index>: _TextIndex<Index.Value> where Index: TextIndex {
    
    private var wrapped: Index
    
    init(_ wrapped: Index) {
        self.wrapped = wrapped
    }
    
    override func insert(key: String, value: Value) {
        wrapped.insert(key: key, value: value)
    }
    
    override func search<S>(prefix: S) -> TextIndexSearchResult<Value> where S : StringProtocol {
        wrapped.search(prefix: prefix)
    }
}
