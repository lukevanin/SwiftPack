import Foundation

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
    
    private var elements = [(key: String, value: Int)]()
    
    subscript(key: String) -> Int? {
        get {
            elements
                .first { element in
                    element.key == key
                }
                .map { element in
                    element.value
                }
        }
        set {
            // Find the index of the element with the given key, if one exists.
            let index = elements.firstIndex { element in
                element.key == key
            }
            if let index = index {
                // An element already exists with the given key.
                if let newValue = newValue {
                    // The new value is provided. Replace the existing value.
                    elements[index].value = newValue
                }
                else {
                    // The new value is nil. Remove the existing element.
                    elements.remove(at: index)
                }
            }
            else {
                if let newValue = newValue {
                    // The element does not already exist, and a new value is
                    // provided. Insert a new element with the given key and
                    // value. Do not insert any element if the value is nil.
                    elements.append((key: key, value: newValue))
                }
            }
        }
    }
    
    func search<S>(prefix: S) -> [Int] where S : StringProtocol {
        elements
            .filter { element in
                element.key.prefix(prefix.count) == prefix
            }
            .sorted { a, b in
                a.key < b.key
            }
            .map { element in
                element.value
            }
    }
}
