import Foundation

///
/// A collection used for accessing text index search results.
///
/// The collection is optimised for the use case where search results are accessed sequentially. The
/// underlying results are returned on demand as they are accessed. Search results can be accessed in O(1)
/// time.
///
/// - Note: Accessing this collection randomly will result in reduced performance up to O(n).
///
class SequentialIndexedCollection<Iterator, Element>: Collection where Iterator: IteratorProtocol, Iterator.Element: BinaryInteger {
    
    let startIndex: Int = 0
    
    let endIndex: Int
    
    private var currentIndex = -1
    private var cachedIndices = [Int]()
    private var indices: Iterator
    
    private let elements: [Element]
    
    init(count: Int, indices: Iterator, elements: [Element]) {
        self.endIndex = count
        self.indices = indices
        self.elements = elements
        self.cachedIndices = Array(repeating: 0, count: count)
    }

    subscript(position: Int) -> Element {
        guard position >= startIndex && position < endIndex else {
            fatalError("Index \(position) out of range (\(startIndex)...\(endIndex - 1)")
        }
        iterate(upto: position)
        let index = cachedIndices[position]
        return elements[index]
    }

    func index(after i: Int) -> Int {
        i + 1
    }
    
    private func iterate(upto index: Int) {
        while currentIndex < index {
            guard let index = indices.next() else {
                return
            }
            currentIndex += 1
            cachedIndices[currentIndex] = Int(index)
        }
    }
}
