# City Search

**LUKE VAN IN, JUNE 2022**

_City Search_ is an iOS app that allows the user to search for cities by 
name, and see the city on a map.

The user enter the name of a city or cities to search for. Matching cities are 
displayed in a list, which updates as the user enters text into the search 
field. The user can tap on a search result to show a map with the location of 
the city. 

## Project Overveiew

The project demonstates a solution to the challenges of perform a text search on 
a non-trivial amount of data. The data set is provided as a JSON encoded file 
containing 200k records. Each record has:
- The name of a city (unicode string).
- The two-letter code of the country in which the city is located.
- Geographical coordinates of the city (double-precision floating point).

Our solution provides an implementation of a _trie_ data structure, with full 
unicode support, and the ability to store generic value types. Our solution 
allows queries to be resolved with sub-milliscond latency. We also provide an 
efficient iterator and collection for accessing search results, allowing 
interactive search response times of **1.5 ms** for top-level searches (one 
character). 

We also provide a solution for improving data loading efficiency, and reducing 
app launch latency. Loading and populating the data structure from the JSON file 
takes a noticable amount of time, up to 11 seconds in some tests. Our solution 
uses an efficient data encoding format to load a pre-filled index from disk. Our 
solution loads and initializes the index from cold launch in **1.2 seconds** 
(iPhone X, Release build).

## System Requirements

This code and app has been tested with the following system:
- MacOS 12.4 Monterey
- Xcode 13.2
- iPhone X
- iOS 15.3
- MacBook Pro, M1 CPU, 16GB RAM

The app is compatible with iOS version 14 and above, in accordance with the, 
requirements of the assessment however this has not been tested.

## Build Instructions

1. Open the project using Xcode 13.2 or above.
2. Connect a suitable iOS device or select a compatible iOS simulator.
3. Press play.

No frameworks or additional dependencies are required.

Note: The scheme has been set to use the _release_ build configuration by 
default, instead of the usual _debug_ configuration. 

## Architecture

Our design generally adheres to _SOLID_ principles:
- Single reponsibility: Our components often serve a single purpose, and usually
have a single reason to change. Our models, repositories, coordinators, and
builders are small and focused. Our search view controller is less small 
and focused, and could benefit from further decomposition.
- Open / Closed: Components are designed to be swapped with other instances 
rather than being modified to change behaviour. Our application coordinator
builder is a counter-example. 
- Liskov Substitution: We rely on substitution to be able to replace instances 
with mocks for testing, use different repositories in our models, and compose
coordinators and `TextIndex` types.
- Interface Segregation: Our interface protocols are narrow. We prefer multiple
smaller interfaces over fewer large ones. Our coordinator pattern is 
one example. 
- Dependency Inversion: Components refer to dependencies using protocols or
type erasing structs, and not concrete implementations.

In addition to the above:
- We favor composition over inheritence, and provide implementations that 
compose objects rather than relying on inheritence hierarchies. An example
is the compositional nature of `TextIndex` and `Coordinator`. We use inheritence
where required by `UIKit` to implement view controllers and views.
- We use dependency injection and provide dependencies to objects, rather than 
requiring objects to create dependencies. We construct dependencies in builders
and pass them to constructed artefacts.
- We follow the _law of demeter_ or _principle of least knowledge_, and avoid
accessing details of dependencies. 

Our source code makes use of the standard _Model-View-Controller_ architecture, 
with some additional design pattern categories such as _Builder_, _Coordinator_, 
and _Repository_. These categories are described in under the sub-headings 
below. Please refer to the source code in each directory for details on 
specific objects.

### Type-erasure

Erases the type of an instance that conforms to some protocol, so that the 
instances that have _self_ type constraints can be passed and used generically. 
An example of type erasure is the `AnyCollection` which provides type erasure
for types conforming to the `Collection` protocol. We define some custom 
erasures for our own protocols where needed. 

### Builder

Builders encapsulate the procedures for constructing objects. The builder 
abstraction allows object instantiation to be decoupled from the code that uses 
the constructed artefact (Interface seggregation).   

We define a generic `BuilderProtcol` which is a type that produces an artefact. 
We also provide an `AnyBuilder` type erasure. 

### Coordinator

Coordinators encapsulate navigation behaviour. They are used in our app to 
construct and present the initial window, and perform navigation from the search
screen to the map screen.

We define the following coordinators protocols:
- `CoordinatorProtocol`: A generic base type which all coordinators conform to.
- `ActivatingCoordinatorProtocol`: A coordinator that performs navigation when
its `activate` method is called. Encapsulates a specific navigation action, such
as instantiating the main application window and root view controller.
- `PresentingCoordinatorProtocol`: A coordinator that presents a view 
controller, such as by pushing the view controller onto a navigation stack.
- `ContainerCoordinatorProtocol`: A coordinator that contains child 
coordinators. Used to compose a hierarchical tree of coordinators.

We instantiate a static hierarchy of coordinators representing our app in the 
`ApplicationCoordinatorBuilder`. For this demonstration this abstraction is 
definitely superfluous. However under the pretenses that this is a _production 
ready_ app, such an abstraction can be useful in managing the structure of a 
complicated application containing many screens.

### View Controller

Objects inheriting from the standard `ViewController` provided by `UIKit`. View
controllers serve the purpose of moving data from the _model_ to the _view_, 
often transforming the data into a readable form. They also receive input from
views and perform actions.

Our app uses a view controller for the search screen and map screen.

### View

Renders content on the display. Views only display content. 

We provide custom `UIView` subclasses for search result rows and placeholders.

### Model

Models represent the source of truth in an application. Information displayed in
the app should be derived from a model. User input may be sent to a model to be 
processed by a Models may use other components to provide access to external 
resources.

We define a single `CitySearchModel` which provides cities filtered by name 
matching a given prefix. The model receives search queries via a method, and 
outputs search results through a publisher. The model uses a repository to 
provide search results. 

### Repository

Provides access to data. Repositories are often used by models, to provide data
from external resources, which the model transforms into a canonical internal
representation. 

The model / repository separation is more commonly associated with the 
_Model-View-Presenter_ design pattern than with _MVC_. We use it here to 
encapsulate search functionality and isolate the details of the search 
implementation from the business logic of the app. 

Specific search methods are implemented by repositories, while the interface of 
accepting queries and publishing results is managed by the model. This allows 
the search implementation to be changed without affecting the behaviour of 
the app. 

For example, if we were to use a backend API for providing the search results, 
the search repository can be replaced with one which performs network calls and 
deserializes data, and the rest of the app can continue working exactly the 
same as before.    

### Index

We define a `TextIndex` protocol for storing and fetching text in an index. The
text index provides methods for inserting values with specific keys, and 
retrieving a _sequence_ of values whose keys match a given prefix.

We provide implementations of:
- `TrieTextIndex`: A text index using a _trie_ data structure for efficiently 
locating values matching a given query. Includes an efficient iterator 
implementation for accessing values in a search result.  
- `LinearTextIndex`: A text index which uses linear search to locate values 
matching a given query. Used in performance tests to compare theoretical 
predictions with real world behaviour.
- `CaseInsensitiveTextIndex`: Provides case-insensitive search capabilities on 
any `TextIndex`.

We also provide a `SequentialIndexedCollection` which provides a `Collection` 
interface for accessing search results efficiently in sequence. 

### Data Codec

Capabilities for encoding and decoding trivial and complex data types to and 
from a transportable data format. Used to store the cities and index on disk in 
a form that can be loaded efficiently at runtime.

We define a `DataCodable` protocol that conforming types implement. We also 
define default data encoding implementations for:
- 8, 16, 32, and 64 bit signed and unsigned integers
- 32 and 64 bit floating point numbers
- boolean
- optional, array and dictionary of any wrapped type conforming to `DataCodable`

We also define a `VarUInt64` type, which encodes a 64-bit integer to a variable
number of bytes depending on its value, for efficient and flexible storage of a 
wide range of values.

## Trie Data Structure

The trie data structure stores text strings in a way that they can efficiently 
located. The trie stores nodes in a tree structure, starting at a root node 
which contains child nodes, which in turn contain child nodes.

Each node in the trie forms a complete sub-tree. That is to say, any particular
node has the same structure and purpose as any other node. There is no 
distinction between child and parent nodes, or branch and leaf nodes.

The trie nodes correspond to characters in the stored text. The child nodes of 
the root node correspond to the first letters of all of the strings stored in 
the trie. The children of these nodes correspond to the second letter of the 
stored strings, and so on for each letter of each string stored in the text. 

The efficiency of locating text in the trie is achieved through the 
divide-and-conquor algorithm used to perform queries. The search algorithm can 
eliminate the majority of contained data at each step, needing to only visit
as many nodes as there are characters in the search query. Search queries are
often small (a few dozen characters at most), compared to the data set which can
be large (hundreds of thousands of entries).

The basic operation of the trie consists of two parts: insertion and querying. 
We will describe each of these in detail below in relation to our 
implementation.  

Additional design considerations for our implementation include:

1. Our data set contains unicode characters. Our trie must be able to store and 
locate text containing unicode characters.
2. Our data set contains values associated with the same text. We need to be 
able to store and return multiple values for a given string.

These requirements are contrary to common trie implementations and increase the 
complexity of the solution. 

1. Trie nodes commonly use a array of a fixed size matching the alphabet to 
store child nodes. This allows the search algorithm to locate a child node 
matching a given character in _O(1)_ time. For our use case pre-allocating an
array of sufficient size to store all unicode characters at even just one level
is prohibitive. We use a dictionary at each level of the trie to to store 
child nodes associated with characters. This reduces efficiency of locating 
child nodes to _O(log(alphabet))_.
2. We use an array of values per trie node. The values are maintained in sorted
order so that their order is predictable in the returned results set.

For our use case, we define the key as the name of the city, and the value as 
a 32-bit integer index of the city record in our data set. The result from a 
search query is a set of indices of cities in the data set. We iterate over the
indices, look up the city for each index, and collect the cities into a list. 

### Insertion

Our interface accepts a generic value and _key_ string which is the text that is 
used to locate the value.

- Use a variable to keep track of the current node. Set the current node to the 
root node.
- Visit each character in the _key_ string.
- Locate the child node matching the current character. 
- If the child node does no exist then create it and add it to the dictionary
of child nodes.
- Set the current node to the child node. 
- Repeat to the next character of the _key_ string.
- When we have visited all of the characters in _key_, add the value to the list
of values for the current node.

At the end of this process the value is stored in the trie. We repeat this 
process for each key and value pair that we want to store in the trie. 

### Query

Values can be located in the trie using a given _prefix_ string. The search 
algorithm returns all values whose key begins with the provided _prefix_.

- Set the current node to the root node.
- Visit each character in the _key_ string.
- Locate the child node matching the current character. 
- If the child node does no exist then we can determine that the _prefix_ does 
not match any stored key and we can return an empty result. 
- Set the current node to the child node. 
- Repeat to the next character of the _prefix_ string.
- When we have visited all of the characters in _prefix_, the current node will
refer to the root node of the subtree containing the result set.

At the end of the query procedure we return an iterator that visits all of the 
descendants of the subtree in order. 

### Performance

The performance of the trie, combined with the efficient data retrieval, allowd 
search queries to be fulfilled within a few milliseconds (1.2 ms on iPhone X).

Queries are fulfilled in O(P log A) time, where:
- P is the length of query prefix (due to linear scan through each charater in 
the prefix).
- A is the size of the alphabet (due to dictionary lookup for child nodes at 
each node level). 

While performance is well within acceptable limits, further improvdements may
be made:
- Child nodes and values are kept in sorted lists. The lists are sorted when 
they are updated, which may take O(n) time best case. A more efficient approach 
would be to use binary insertion sort when inserting values O(log n).
- Child nodes are stored in a dictionary. It may be more efficient to store 
values in a sorted array and use binary search to locate nodes. 

## Data Encoding

We provide a systematic approach for encoding and decoding objects to a data 
representation. We use store our trie and data set on disk using this format so
that it can be loaded efficiently at runtime.

Our implementation uses 15MB of disk space to store the trie and data set, and 
takes 1.2 seconds to load. A comparable implementation that loads the data from 
the provided JSON file uses 19MB to store only the data set, and takes up to 
11 seconds to load. The above results were obtained using an iPhoneX, with a 
release mode build using _fastest/smallest_ optimization.

We define a `DataCodable` protocol which has methods for instantiating a type 
from given data, and returning data for a specific instance. We define default
implementations for built-in fixed width integers, flaoting point numbers, and 
booleans. We also define implementations for optionals, arrays, and dictionaries
whose elements conform to `DataCodable`. 

We also implement `DataCodable` for our text index and repository objects. 

We use the `IndexedCitiesRepository` representation as the contents of the file
which is stored on disk. This object contains both the cities data set, as well
as a filled trie text index. This data structure is created in the 
`IndexedCitiesRepositoryDataCodablePerformanceTests` unit test and added as an 
attachment. We use the contents of this attachment, copied into our app, as the
data file which is loaded at runtime.     

## TODO

- Document "test" command line argument
- Use binary insertion sort when inserting characters and values into trie 
nodes to avoid having to re-sort each array when a value is inserted. 
- Localize text.
- Test non-latin characters (e.g. emoji)
- Logging abstration.
- Metrics.
- Keyboard avoidance for placeholders.
- Include country in search index.
- AnyTextIndexWrapper copy-on-write + tests
