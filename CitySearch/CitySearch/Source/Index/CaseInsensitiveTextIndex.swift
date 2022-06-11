import Foundation

///
/// Performs case insensitive searches on an underlying `TextIndex`.
///
/// Wraps a `TextIndex` allowing queries to match keys regardless of case.
///
/// 1. Keys are converted to uppercase when a value is inserted.
/// 2. Queries are converted to uppercase when a search is performed.
///
struct CaseInsensitiveTextIndex: TextIndex {
    
    var index: TextIndex
    
    ///
    /// Inserts a value into the index using the provided key.
    ///
    mutating func insert(key: String, value: Int) {
        index.insert(key: transform(key), value: value)
    }

    ///
    /// Searches for a value using the provided index.
    ///
    /// - Parameter prefix: The case insensitive prefix of the values to search for.
    /// - Returns: Values whose key starts with the given prefix.
    ///
    func search<S>(prefix: S) -> TextIndexSearchResult where S : StringProtocol {
        index.search(prefix: transform(prefix))
    }
    
    ///
    /// Transforms the given key or prefix into a canonical form where charaters are equivalent regardless
    /// of case.
    ///
    private func transform<S>(_ input: S) -> String where S: StringProtocol {
        input.localizedUppercase
    }
}
