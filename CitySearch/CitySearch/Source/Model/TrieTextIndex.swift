import Foundation

///
/// A text index using a trie structure to store and retrieve values associated with keys.
///
/// A trie is a hash table that provides efficient access to stored values. The trie allows values to be stored
/// based on a key consisting of a string of characters from a given set, referred to as the alphabet.
///
/// ## Operation
///
/// The trie is implemented as a hierarchical nested tree tructure. Each node in the tree is an array, where
/// each element corresponds to a character in the alphabet, and contains a child trie structure.
///
/// ### Insert
///
/// When a value is stored in the trie:
/// - A variable is used to keep track of the current node. The current node is set to the root or top-level
/// node of the trie.
/// - The first character of the key is examined.
/// - The corresponding child node is located in the current node for the position corresponding to the
/// character. If a node is not currently present, then a new node is created and inserted at the
/// required position.
/// - The current node is set to the child node.
/// - The next charater in the key is examined, and the process repeats until all of the characters in the key
/// have been examined.
/// - The value is set on the current node. The value is now stored in the trie, and can be retrieved at a
/// later time
///
/// ### Lookup (exact match)
///
/// When an exact key is provided for a value to be retrieved:
/// - The current node is set to the root or top-level node of the trie.
/// - The first character of the key is examined.
/// - The corresponding child node is located in the current node for the position corresponding to the
/// character. If a node is not currently present, then the procedure ends and a nil value is returned.
/// - The current node is set to the child node.
/// - The next charater in the key is examined, and the process repeats until all of the characters in the key
/// have been examined.
/// - The value for the current node is returned.
///
/// ### Search (match prefix)
///
/// When a key is provided for a value to be retrieved:
/// - The current node is set to the root or top-level node of the trie.
/// - The first character of the key is examined.
/// - The corresponding child node is located in the current node for the position corresponding to the
/// character. If a node is not currently present, then the procedure ends and a nil value is returned.
/// - The current node is set to the child node.
/// - The next charater in the prefix is examined, and the process repeats until all of the characters in the
/// prefix have been examined.
/// - An iterator is returned for the current node. The iterator returns all of values for all of the descendants
/// of the node in alphabetical order.
///
struct TrieTextIndex: TextIndex {
    
    subscript(key: String) -> Int? {
        get {
            return nil
        }
        set {
            
        }
    }
    
    func search<S>(prefix: S) -> AnyIterator<Int> where S : StringProtocol {
        return AnyIterator {
            return nil
        }
    }
}
