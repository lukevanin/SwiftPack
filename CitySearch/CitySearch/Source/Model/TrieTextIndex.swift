import Foundation

///
/// A text index using a trie structure to store and retrieve values associated with keys.
///
/// A trie is a hash table that provides efficient access to stored values. The trie allows values to be stored
/// based on a key consisting of a string of characters.
///
/// ## Operation
///
/// The trie is implemented as a hierarchical nested tree tructure. Each node in the tree is a dictionary, where
/// each keys correspond to a character in the alphabet, and contains a child trie node.
///
/// ### Insert
///
/// When a value is stored in the trie:
/// - A variable is used to keep track of the current node. The current node is set to the root or top-level
/// node of the trie.
/// - The first character of the key is examined.
/// - The corresponding child node is located in the current node corresponding to the character. If a node is
/// not currently present, then a new node is created and inserted for the current character.
/// - The current node is set to the child node.
/// - The next charater in the key is examined, and the process repeats until all of the characters in the key
/// have been examined.
/// - Once the entire key has been traversed, the value is appended to values for the current node.
///
/// ### Search (match prefix)
///
/// When a key is provided for a value to be retrieved:
/// - The current node is set to the root or top-level node of the trie.
/// - The first character of the key is examined.
/// - The corresponding child node is located in the current nodecorresponding to the  character. If a child
/// node is not present, then the procedure ends and an empty result is returned.
/// - The current node is set to the child node.
/// - The next charater in the prefix is examined, and the process repeats until all of the characters in the
/// prefix have been examined.
/// - Once the entire key has been traversed, an iterator is returned for the current node. The iterator
/// provides all of values for all of the descendants of the node. Values are order alphabetically according to
/// the key associated with the value. If multiple valiues are associated with one key, the values are returned
/// in ascending order.
///
struct TrieTextIndex: TextIndex {

    ///
    /// A node within the trie.
    ///
    /// Nodes are arranged in a hierarchical tree structure. Each node may contain:
    /// - A value
    /// - Zero or more child nodes
    ///
    private struct Node {
        
        /// Values assigned to the node. V
        private(set) var values = [Int]()
        
        /// Characters which have corresponding child nodes in this node. Used to determine the order
        /// in which nodes are traversed.
        private(set) var characters = [Character]()

        /// Child nodes contained by this node. Each position in the child node list corresponds to a
        /// character in the alphabet.
        private(set) var childNodes = [Character: Node]()
        
        ///
        /// Inserts the value for the key and returns the existing value.
        ///
        /// - Parameter key: Unique key used to locate the value.
        /// - Parameter value: Value to store for the key.
        /// - Returns: Previous value for the key if one is present.
        ///
        mutating func insert<S>(key: S, value: Int) where S: StringProtocol {
            // Examine the first character in the given key.
            guard let character = key.first else {
                // Key is empty. Insert the given value at the current node.
                #warning("TODO: Use a binary insertion sort when inserting a new value")
                values.append(value)
                values.sort()
                return
            }
            // Get the child node corresponding to the character.
            var childNode: Node! = childNodes[character]
            if childNode == nil {
                // The child node does not exist yet. Create it and insert it
                // into the array of child nodes.
                childNode = Node()
                #warning("TODO: Use binary insertion sort to insert character")
                characters.append(character)
                characters.sort()
            }
            // Insert the value with the remainder of the key into the
            // child node.
            let suffix = key.dropFirst()
            childNode.insert(key: suffix, value: value)
            childNodes[character] = childNode
            characters.append(character)
        }
        
        ///
        /// Finds the node matching the given prefix.
        ///
        /// - Parameter prefix: The string to search for.
        /// - Returns: The node where the key prefix matches the given query, or nil if no node
        /// is found.
        ///
        func search<S>(query: S) -> Node? where S : StringProtocol {
            guard let character = query.first else {
                // No more characters are available in the query. The whole
                // query has been evaluated. Return the current node.
                return self
            }
            guard let childNode = childNodes[character] else {
                // No node was found matching the current character. There is
                // no node that matches the query. Return nil.
                return nil
            }
            // We have found a child node that matches the current character of
            // the query. Ask the child node to find the node that matches the
            // next character in the query.
            let suffix = query.dropFirst()
            return childNode.search(query: suffix)
        }
    }
    
    ///
    /// Iterates through all of the descendants of a given node, returning all of the values contained within
    /// the node tree
    ///
    private struct NodesIterator: IteratorProtocol {
        
        ///
        /// Maintains state while traversing the node tree.
        ///
        struct NodeIterator {
            let node: Node
            var characters: IndexingIterator<[Character]>
            var values: IndexingIterator<[Int]>
            
            init(node: Node) {
                self.node = node
                self.characters = node.characters.makeIterator()
                self.values = node.values.makeIterator()
            }
            
            mutating func nextValue() -> Int? {
                values.next()
            }
            
            mutating func nextChild() -> Node? {
                characters.next().flatMap { character in
                    node.childNodes[character]
                }
            }
        }
        
        private var stack = [NodeIterator]()
        
        init(node: Node) {
            self.stack = []
            firstNode(node: node)
        }
        
        private mutating func firstNode(node: Node) {
            // Use depth-first traversal to find the first descendant node.
            var current: Node! = node
            while current != nil {
                var iterator = NodeIterator(node: current)
                // Find the next child node for the current node
                current = iterator.nextChild()
                // Append the node to the stack
                stack.append(iterator)
            }
        }

        private mutating func nextNode() {
            // Use depth-first traversal to find the first descendant node.
            while stack.count > 0 {
                // Find the next child node for the current node
                if let childNode = stack[stack.count - 1].nextChild() {
                    // Append the node to the stack and repeat.
                    stack.append(NodeIterator(node: childNode))
                }
                else {
                    // No more child nodes. Remove this node from the stack
                    // and try the parent node.
                    stack.removeLast()
                }
            }
        }
        
        mutating func next() -> Int? {
            while stack.count > 0 {
                if let value = stack[stack.count - 1].nextValue() {
                    return value
                }
                else {
                    // No more values for the current node. Try the next
                    // character.
                    nextNode()
                }
            }
            return nil
        }
    }
    
    private var root = Node()
    
    subscript(key: String) -> Int? {
        get {
            return nil
        }
    }
    
    mutating func insert(key: String, value: Int) {
        root.insert(key: key, value: value)
    }
    
    func search<S>(prefix: S) -> AnyIterator<Int> where S : StringProtocol {
        guard let node = root.search(query: prefix) else {
            return AnyIterator { return nil }
        }
        return AnyIterator(NodesIterator(node: node))
    }
}
