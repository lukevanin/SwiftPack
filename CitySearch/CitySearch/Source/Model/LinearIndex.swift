import Foundation

///
/// A text index that is implemented using linear search to locate elements.
///
/// A collection of key-value pairs. Queries are fulfilled using a simple but inefficient linear search algorithm.
/// where, each key is matched against the query.
///
/// - Note: This index should not be used in real world applications. It exists as a worst case baseline
/// comparison for more efficient implementations which should be used instead.
///
struct LinearTextIndex: TextIndex {
    
    struct Element {
        let key: String
        var values: [Int]
    }
    
    private var elements = [Element]()
    
    mutating func insert(key: String, value: Int) {
        // Find the index of the element with the given key, if one exists.
        let index = elements.firstIndex { element in
            element.key == key
        }
        if let index = index {
            // An element already exists with the given key. Insert the value if
            // it is not already in the array.
            if elements[index].values.contains(value) == false {
                // The given value is not associated with the key yet. Append
                // the value and sort the array.
                elements[index].values.append(value)
                elements[index].values.sort()
            }
        }
        else {
            // The element does not already exist. Insert a new element with
            // the given key and value.
            elements.append(Element(key: key, values: [value]))
        }
    }
    
    func search<S>(prefix: S) -> AnyIterator<Int> where S : StringProtocol {
        let iterator = elements
            .filter { element in
                element.key.prefix(prefix.count) == prefix
            }
            .sorted { a, b in
                a.key < b.key
            }
            .map { element in
                element.values
            }
            .joined()
            .makeIterator()
        return AnyIterator(iterator)
    }
}
