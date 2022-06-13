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
struct TrieTextIndex<Value>: TextIndex where Value: Comparable {
        
    ///
    /// A single character in a key or search prefix
    ///
    struct CodeUnit: Hashable, Comparable {
        
        let scalarValue: UInt32

        init(character: Character) {
            #warning("TODO: Support multi-scalar characters")
            let unicodeScalar = character.unicodeScalars[character.unicodeScalars.startIndex]
            self.init(unicodeScalar: unicodeScalar)
        }
        
        init(unicodeScalar: UnicodeScalar) {
            self.scalarValue = unicodeScalar.value
        }
        
        static func < (lhs: CodeUnit, rhs: CodeUnit) -> Bool {
            lhs.scalarValue < rhs.scalarValue
        }
    }

    ///
    /// A node within the trie.
    ///
    /// Nodes are arranged in a hierarchical tree structure. Each node may contain:
    /// - A value
    /// - Zero or more child nodes
    ///
    fileprivate struct Node {
        
        /// Number of values contained within the node and all of its descendants.
        private(set) var count = Int(0)
        
        /// Values assigned to the node.
        private(set) var values = [Value]()
        
        /// Characters which have corresponding child nodes in this node. Used to determine the order
        /// in which nodes are traversed.
        private(set) var characters = [CodeUnit]()

        /// Child nodes contained by this node. Each position in the child node list corresponds to a
        /// character in the alphabet.
        private(set) var childNodes = [CodeUnit : Node]()
        
        ///
        /// Inserts the value for the key and returns the existing value.
        ///
        /// - Parameter key: Unique key used to locate the value.
        /// - Parameter value: Value to store for the key.
        /// - Returns: Previous `true` if a value was inserted, or false otherwise.
        ///
        mutating func insert<S>(key: S, value: Value) -> Bool where S: StringProtocol {
            // Examine the first character in the given key.
            guard let character = key.first else {
                // Key is empty. Insert the given value at the current node.
                if values.contains(value) == false {
                    count += 1
                    #warning("TODO: Use a binary insertion sort when inserting a new value")
                    values.append(value)
                    values.sort()
                    return true
                }
                else {
                    return false
                }
            }
            let scalar = CodeUnit(character: character)
            // Get the child node corresponding to the character.
            if childNodes[scalar] == nil {
                // The child node does not exist yet. Create it and insert it
                // into the array of child nodes.
                childNodes[scalar] = Node()
                #warning("TODO: Use binary insertion sort to insert character")
                characters.append(scalar)
                characters.sort()
            }
            // Insert the value with the remainder of the key into the
            // child node.
            let suffix = key.dropFirst()
            let inserted = childNodes[scalar]!.insert(key: suffix, value: value)
            if inserted == true {
                // Increment the value count if a value was inserted.
                count += 1
            }
            return inserted
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
            guard let childNode = childNodes[CodeUnit(character: character)] else {
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
    /// Iterates through all of the descendants of a given node and  returning all of the values contained
    /// within the node tree
    ///
    /// The iterator uses a stack to maintain state for the current node. The stack contains an array of
    /// node iterators. The top of the stack refers to the root of the node subtree which is being iterated over.
    /// The bottom of the stack refers to the current node.
    ///
    /// When initialized, the stack contains just the root node. The stack grows in depth as the descendants
    /// nodes of the root node are visited. A node is removed from the stack once all of its descandants have
    /// been iterated over. The iterator completes when all descendants of the root node have been
    /// iterated over.
    ///
    private struct NodesIterator: IteratorProtocol {
        
        ///
        /// Maintains state while traversing the node tree.
        ///
        struct NodeIterator {
            let node: Node
            var characters: IndexingIterator<[CodeUnit]>
            var values: IndexingIterator<[Value]>
            
            init(node: Node) {
                self.node = node
                self.characters = node.characters.makeIterator()
                self.values = node.values.makeIterator()
            }
            
            mutating func nextValue() -> Value? {
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
            self.stack = [NodeIterator(node: node)]
        }
        
        ///
        /// Returns the next value in the tree.
        ///
        ///
        ///
        /// The iteration step performs the following operations:
        /// - Set the current node to the node at the bottom of the stack.
        /// - Return the next value for the current node.
        /// - If no more values are available on the current node then we can iterate over the children of
        /// the current node. Get the child node for the current node and add it to the stack.
        /// - If no more child nodes are available then iteration is complete for this node. Remove the
        /// node from the stack.
        /// - Repeat these steps until the stack is empty.
        ///
        /// - Returns: The next available value, or nil if no more values are available.
        ///
        mutating func next() -> Value? {
            // Use depth-first search to find the next value in the sequence
            while stack.count > 0 {
                // Find the next child node for the current node
                if let value = stack[stack.count - 1].nextValue() {
                    // Return the value for the current node.
                    return value
                }
                else if let childNode = stack[stack.count - 1].nextChild() {
                    // Append the node to the stack and repeat.
                    stack.append(NodeIterator(node: childNode))
                }
                else {
                    // No more child nodes and no more values. Remove this node
                    // from the stack and try the parent node.
                    stack.removeLast()
                }
            }
            // No more nodes to visit. We are done iterating.
            return nil
        }
    }
    
    fileprivate var root = Node()
    
    ///
    /// Inserts a value associated with a given key.
    ///
    /// Multiple values can be associated with any given key. Inserting multiple values for a given key
    /// associates all fot eh values with the key. Searches matching the key will returb all of the values for
    /// the key.
    ///
    /// A value may only be associated once with a given key. A key may not be associated with duplicate
    /// values.
    ///
    /// - Parameter key: Key to associated the value with.
    /// - Parameter value: Value to store for the key. The valid range is (0 ... 2^32 - 1)
    ///
    mutating func insert(key: String, value: Value) {
        root.insert(key: key, value: value)
    }
    
    func search<S>(prefix: S) -> TextIndexSearchResult<Value> where S : StringProtocol {
        guard let node = root.search(query: prefix) else {
            return TextIndexSearchResult(
                count: 0,
                iterator: AnyIterator { return nil }
            )
        }
        return TextIndexSearchResult(
            count: Int(node.count),
            iterator: AnyIterator(NodesIterator(node: node))
        )
    }
}


// MARK: Equatable conformance


extension TrieTextIndex: Equatable {
    
}


extension TrieTextIndex.Node: Equatable {
    
}


extension TrieTextIndex.CodeUnit: Equatable {
    
}


// MARK: DataCodable conformance


extension TrieTextIndex: DataCodable where Value: DataCodable {
    init(decoder: DataDecoder) throws {
        self.init(
            root: try Node(decoder: decoder)
        )
    }
    
    func encode(encoder: DataEncoder) {
        root.encode(encoder: encoder)
    }
}


extension TrieTextIndex.Node: DataCodable where Value: DataCodable {
    
    init(decoder: DataDecoder) throws {
        self = TrieTextIndex.Node(
            count: Int(try VarUInt64(decoder: decoder).value),
            values: try [Value](decoder: decoder),
            characters: try [TrieTextIndex.CodeUnit](decoder: decoder),
            childNodes: try [TrieTextIndex.CodeUnit : TrieTextIndex.Node](decoder: decoder)
        )
    }
    
    func encode(encoder: DataEncoder) {
        VarUInt64(count).encode(encoder: encoder)
        values.encode(encoder: encoder)
        characters.encode(encoder: encoder)
        childNodes.encode(encoder: encoder)
    }
}


extension TrieTextIndex.CodeUnit: DataCodable {
    
    init(decoder: DataDecoder) throws {
        let scalar = try VarUInt64(decoder: decoder)
        #warning("TODO: Safe unwrap")
        let unicodeScalar = UnicodeScalar(UInt32(scalar.value))!
        self.init(unicodeScalar: unicodeScalar)
    }
    
    func encode(encoder: DataEncoder) {
        VarUInt64(scalarValue).encode(encoder: encoder)
    }
}
