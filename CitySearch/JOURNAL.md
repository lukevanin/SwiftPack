# Developer Journal

### 07/06

## Overview

We are presented with a task to search for cities whose name begins a given 
query string.

The data set is presented as a file of around 19MB containing about 200k entries 
serialized as JSON.

The user must be able to filter this list of entries by entering a string. 

The app must display a list of cities where the combined name and state of the 
city begins with the entered query. 

User experience is important. The user interface must update as the query is 
entered. The specification states that the search time should be 
sublinear - that is to say - it should run faster than a niave approach that 
compares the  query against each item in the list.

## Challenges

The challenges presented to us need to be solved:

1. Load the data from storage.
2. Filter the entries as the user enters a query.
3. Show a list of entries to the user.

## Solutions

Initial thoughts on approach:

### Filtering

Filtering the large data set efficiently is essentially the root of the problem 
we are being asked to solve. We will need to use a data structure that allows 
the information to be retrieved efficiently. 

Initial thought is to use a trie data structure to be able to efficiently locate 
text matching a given prefix.

_Pros:_

- Data can be located efficiently. The asymptotic complexity of locating the 
node matching a given prefix length P is of order O(P). Inserting N nodes with 
average key length K is in the order of O(N log K).
- Data can be retrieved efficiently. Once the initial node is matched, the 
entire subset of the data can be accessed  simply by visiting the descandants of 
the node. This iteration can be abstracted as a Collection, so that the data can 
accessed by the app easily. 
- Memory usage should be within a reasonable limits to allow the entire data set 
to be loaded into memory. The source  file takes about 19MB of space on disk, 
which includes the overhead of storing content as JSON, such as extra formatting 
characters (`"`, `[]`, `{}`), and extra characters used to encode numbers. The 
data should require less space once it is deserialized. Even if this data is 
stored verbatim in memory is unlikely to exceed the memory available to the app.

_Cons:_
 
- Space for storing nodes can become unwieldy if the dataset contains too many 
different characters. If this turns out to be the case, we will need to remap 
characters in the alphabet to make the nodes a manageble size.  

### Loading

The specification states that startup time is not important, but we would like  
to make this as efficient as  possible, if only to avoid running out of 
memory and/or draining the battery.

The specification mentions that we are allowed to convert the data to a 
different format, as long as the reason can be motivated. 

Initial thoughts are that we can pre-process the data into a form that can be 
read without having to parse string  data, and which ideally matches the data 
structure we will be using at runtime. We may be able to implement a 
command-line utility that converts the data into a binary representation, 
such as a PropertyList or custom format, that can be loaded into our data 
structure directly.

### Targets:

- The search results should update within 200ms if receiving user input. Taking
up to 500ms may be acceptable, but may create the impression of lag or slowness.
Any delay below 200ms is acceptable. It is probably counter-productive to try to 
achieve a latency below ~33ms to ~16ms (or 30 to 60 frames per second). With 
this in mind, a latency in the order of a few milliseconds should be achievable.
- The app should launch and be usuable within 1 second if possible. Luanching 
the app after installation or after the device is rebooted, may incur take 
longer due to extra overhead outside of our control (e.g. iOS caching linked 
libraries).
- The app should consume a "reasonable" amount of memory, in the order of not 
more than 60MB. Up to 200MB of memory may be used if necessary. Higher memory 
usage should be unnecessary.     

### Displaying data

Displaying the results presents no significant challenge. UIKit provides 
UICollectionView which can display large amounts of data efficiently. It has a 
proven track record and predictable behaviour, making it an obvious choice for 
this application. We are unlikely to be able to implement a better solution 
ourselves.

### Advanced solutions

It would also be nice to be able to load only as much data as we need, and avoid 
having to load it all into memory at once. A possible solution would be to store 
some N levels of the trie nodes as separate files. That way if we want to locate 
data we can easily find the file matching the initial prefix, then use the trie 
to locate data within the file.

## Approach

### Testing

Implement basic sanity tests and "happy path" behaviour based on the test cases 
in the specification. 

Consider tests for edge cases, such as:
- Empty query
- Query length exceeding the longest stored value
- Store and retrieve values containing characters not in the alphabet: numbers, 
upper and lower case, and unicode  characters.

Measure a baseline worst case for loading and filtering the data. We will use 
JSON codable to load the data into an array, and worst case linear search. This 
will form the basis of our slow but correct approach reference implementation
which we can compare our performant but complicated implementation against.

We will need to implement performance tests, which estimates real world query 
performance using random data.

We will also need to implement tests using the real data that is going to be 
used in the app.

We will need to implement tests for the other structural and user interface 
components that may be used by the app, to ensure the data flows correctly 
through the app, and that the results are displayed correctly to the user. 

We may be able to create a user interface integration tests that measures 
realtime performance of the UI.

Preferrably we should implement all of these tests before starting any 
development so that we have a working solution as  soon as possible.

### User Interface

We will use UIKit and code-only layout. We will not be using Storyboards or 
SwiftUI.

Benefits of using UIKit:
- Tried and tested and used by millions of applications over decades.
- Predictable: Edge cases are (mostly) well known, and can be avoided.
- Flexible: Provides for changing existing behaviour, and implementing custom 
functionality.
- Performant: UIKit generally provides a smooth and responsive user experience 
when used correctly.

Disadvantages of using UIKit:
- Code is imperative, often requiring lots of lines of repetative code for even 
basic tasks. This often makes  development slow and prone to bugs.

Initial performance testing was conducted in iOS simulator on M1 MacBook Pro:

- The data set appears to contain 209,557 entries.
- Loading data takes ~6ms. Using memory mapping reduces this below 1ms, 
- Parseing memory-mapped data into NSObjects using JSONSerialization 
takes ~300ms.  
- Parseing memory-mapped data into a Codable struct using JSONDecoder 
takes ~2s.

* Note: Memory usage appears to be misreported. Memory consumption is reported 
to be about 19KB. Peak memory usage is  reported as 0KB. This may be due to 
tests being run on the simulator. Using a real device may produce more useful 
metrics.

### 08/06

While implementing the trie insertion algorithm it occurred to me to check if 
the data set contains multiple values which have the same city and country. This 
turns out to be the case. For example, "New York Mills, US" occurs twice in the
data set. 

Up until this point I assumed that key-value pairs were unique, and implemented
tests to check that inserting a value with a key that was already present in the
index would replace the existing value.

This new realisation will require some changes to be made. A trie structure can 
still be used, however instead of each node needs to store an array of values 
instead of just storing a single value. The order of values is not defined by 
the specification, but a reasonable approach is to store and return values in 
the order that they were inserted.

Another consideration is the handling of the space and delimiting characters. 
The specification indicates that users would like to search by city and 
country separated by a comma, and some cities contain spaces in their names.

Handling extra characters that are not in the alphabet has some implications 
for performance.

If we only needed to use characters that appear sequentially in the list, then 
the computation for the index of the child node from the character becomes 
trivial: subtract the ordinal value of the first character in the alphabet
from the ordinal value of the given character.

There are a few solutions for this. 

One simple solution is to child nodes in a dictionary instead of in an array. 
This increases search complexity from O(P) to O(P log A), where P is the length 
of the prefix and A is the size of the alphabet. This is still sub-linear but 
not optimal.

Another solution is to pre-process the input string and annotate each character 
with its contextual symantic meaning. e.g. 
- A...Z are annotated as "alphabet".
- Comma, semi-colon, colon are annotated as "delimiter".
- Any other character is annotated as "white-space".

The input can be further procesed to remove duplicate consecutive spaces 
and delimiters.

Child values can be assigned to buckets according to its annotation.  

For now, we will use the first option, where trie child nodes are stored in a 
dictionary, and use the annotated approach if this is performance is still not 
adequate. 

The trie implementation is complete. Test coverage is 100%. Performance seems
to be acceptable:
- Locating a node within a tree containing 1m entries takes much less 
than 1 ms.
- Performing 100k searches on a tree containing 100k entries takes 300ms.

**Performance**

Performance seems to scale exactly linearly with the number of queries. 100k 
queries on a set containing 100k entries takes ~400ms, compared to 10k queries 
on a data set containing 10k entries which takes ~40ms.

Compared to the linear text index, queries using the the trie text index are 
~100x faster.

Performing 1k queries on a data set containing 1k entries takes ~800ms. The trie 
index can perform 200k queries in the same amount of time (200x faster). 
Performing 1k queries with the trie index takes 10ms (80x faster).

The next step is to combine the text index with the array of data, so that we
can return entities related to keys.

### 09/06

We need to provide a search model object which can provide search results for 
the application. The model needs to:
- Load the searchable data from a file.
- Create a key for each item in the list.
- Fill the index structure with the key and index of each item.
- Provide an interface for retrieving items based on a key prefix.

The model should perform the load and search operations asynchronously on a 
background thread, so that the caller and main thread are not blocked waiting
for operations to complete.

Loading data would currently take some amount of time. Based on current 
performance tests, it would seem to take ~3 seconds (MacBook Pro M1):
- 2 seconds to load and decode JSONd data.
- 1 second to fill the index.

The straightforward approach is to simply load the data at once.

**Amortization**

It may also be possible to amortize the cost over time by reading and filling
the index incrementally in a background thread, and repeat the current query 
as the model is updated. The application could be usable immediately after 
launch, and search results would be back-filled as the data is loaded. 

Amortizing the cost only hides the issue, but does not actually reduce the 
amount of time and resources used.

We could potentially reduce the loading time by storing data in a file format
that is more efficient for loading, such as a binary property list, or other 
binary representation. We could also use a format such as CSV, which would let
us load data line by line, instead of needing to load the entire data set into
memory at once as we need to do with PList and JSON. 

**Memory mapping**

Yet another idea would be to use memory mapping. If we can store the contents
of the trie on disk, in a form that exactly matches how it is used at runtime,
then we do not even need to "load" the data in the usual sense. We can use Data
to open the file with mapping enabled. The file is available immediately but no
actual data is loaded from disk. `Data` is loaded by the operating system on 
demand only when we access the data. A nice additional benefit is that the 
operating system will also automatically free memory when it is no longer being
used.

We will need to have an offline tool that we can run at build time, which
loads the raw JSON data, and creates the binary file for our data structure. An
easy, but potentially fragile, way to do this is to fill the true structure, 
then dereference and save the raw bytes.

At runtime we need to load the data into our structure. We can use `Data` to 
reference the file, then bind our structure to the raw byte pointer.

The risks with this method is that it will only work if the memory layout of the
structure remains consistent. The memory layout used in the tool needs to be 
identical to the memory layout on every device where the data is used. This
should hold true due to data layout requirements for Swift ABI:

https://github.com/apple/swift/blob/main/docs/ABIStabilityManifesto.md#data-layout
https://github.com/apple/swift/blob/main/docs/ABI/TypeLayout.rst

Our trie implementation uses *trivial* data types as defined by ABI, we should
be able to depend on the _bitwise movable_ property to ensure that memory
layout us consistent between runtime invocations. 

Data layout may still vary due to differences in CPU architecture, and compiler
optimisation flags used at build time. We may potentially need to provide data
for multiple environments, and ensure the correct data is loaded at runtime. 

Endiannes could also potentially be a relevant issue. Our demo will probably 
only be running on Apple ARM hardware and devices. We can assume file and 
memory layout is consistent. 

For example, we may have data layouts for all combinations of: 
- CPU: arm64 / x86_64 / x86 (and other older arm architectures)
- Compile time: Debug / Release 

If data compatability does become problematic, a potential solution would be to
define data using C structs. Structs defind by the C language have well known 
and predictable memory layout, largely due to the simplicity of the language. 
The trie structure could access an underlying data structure composed of C 
structs, which could also be encoded and decoded to a raw file format.

Simply storing on disk as it is laid out in memory may not be efficient for 
memory mapping when the data needs to be accessed. If we need to visit multiple
nodes in the tree, the operating system will load the the data from disk in 
chunks or _pages_. The overhead of loading many chunks of data from different 
parts of the disk could introduce latency. This latency should be negligible
on modern SSD hardware. 

---
 
I am undecided / unconvinced as to whether a `TextIndex` should return a 
sequence of characters or an iterator. A lower-level iterator provides greater
flexibility. Using a sequence provides a more _conventional_ API interface. The 
correct answer may become obvious with time.

---

It may be useful for our purposes to implement a `Collection` type that returns 
values lazily. Currently we return search results as a `Sequence`. If we want
to display search results in a UI then we will need to at least know the number
of items in the collection. For now we convert the sequence to an `Array`. This
has the downside that we need to iterate over all of the items in the 
sequence at least once.  

This iteration can increase latency. It would be better if we could return a 
colletion where the number of items is known ahead of time. We can store a 
counter in our trie nodes, and increment the counter whenver a value is inserted
into the node or one of its descendants.

We would need to implement a new type that provides a count, and allows 
sequential iteration.

---  

10/06

Completed UI tests for search. We can work on the UI aesthetics for search as 
well as showing the map view.

---

Added implementation for generic coordinators. Added  

---

11/06

The app conforms to most of the requirements of the specification. Until now we
have been using sample data to test the app. Our tests verify that the app 
behaves as expected in theory. The final challenge is test the app with real 
data to ensure it provides sufficient performance under real world conditions.

We also need to ensure strict conformance to the specification, namely:
- Search should be case insensitive. We can implement this by creating a wrapper
for the text index that normalises the case of the input text when inserting
and searching. By separating this behaviour from the trie text index, our 
implementation and tests become much simpler. We can implement the case wrapper 
and tests independently of the other text index objects. All text index objects 
can benefit from the feature. N+M instead of NxM. 
-  Test that searching works with the full example text including comma, 
spaces, and name of country. Also test extended characters such as emoji and
foreign language characters.

---

Implemented loading data from JSON using straightforward JSON decoder. The app
takes ~5 seconds (MacBook Pro M1) to become usable after launch. The is a delay 
of several seconds when the list displays all of the cities in the dataset when 
the search query is empty. 

It is it is not useful to display all of the cities as the list is too large to 
be scrolled through practically. We can update the behaviour of the app so that 
when the query is empty, the app shows a placeholder with a prompt. We should 
update our model to return an empty result set when the query prefix is empty.
The repository should keep the current behaviour, where it returns all cities
when the query is empty, as this facilitates testing.

It would also be nice to be able to dismiss the keyboard on the search screen,
so that that it is easier to browse the search results.  

---

Performance tests using the `cities.json` file indicates that a significant 
amount of time is spent creating the result set after the initial node is 
located.

In `IndexedCitiesRepositoryUnitTests` we load the `cities.json` then perform two
tests:
 
1. In one test we query each letter of the latin alphabet (A...Z), then 
create an array from the result sequence and count the number of items in the
sequence. The average time is ~500ms.
2. In the other test, we perform the same query but ignore the actual results, 
and thereby avoid the array conversion. The average time is below 1ms.

This seems to indicate that creating the array of results is a significant
cause of latency within the app.

Performance can be improved by implementing a `Collection` type, that
avoids iterating the results, and returns items only as they are needed. We can
take advantage of fact that the collection view will read items in sequential 
order, and return items from the underlying data as they are requested by the 
colletion view: 
- Add a count number to each node in the trie.
- Increment the count whenever a value is added to the node, or one of its
children.
- When returning a result, use the count of the top-level node for the result.

We also need to create a custom collection:
- Create a new class that conforms to `Collection`, that uses the sequence of 
indices from the seqrch results and the list of cities. Use a `currentCount` 
variable to keep track of the number of items that have been retrieved from the 
result sequence. initially this variable will be zero. Use a `cache` array to 
store the indices returned by the result set. Initially this array will contain 
placeholder values. 
- When an item is accessed in the collection and the fetch all of the indices 
in the sequence up to required index. Store the resulting index in the cache 
array, then return the city.

This would amortize the cost of retrieving results, over the time it takes the
user to scroll through the list. Most of the times the user will not scroll
through the entire list of results when the list is large, and so we avoid doing
work that is never needed.
 
---

Implemented `SequentialIndexedCollection`, which provides efficient access to 
search results. Performance tests indicate the following:

- Locating the search result: 0.5ms
- Counting search results using `SequentialIndexedCollection`: 5ms
- Counting search results using `Array`: 500ms

Counting the results using the `SequentialIndexedCollection` is an order of 
magnitude slower than simply returning the node, but still two orders of 
magnitude faster than converting the results to an array.

---

13/06

Loading and populating the index from a JSON file takes ~10 seconds or 
longer. We should try to improve this time if possible.

Our initial approach was to use the iOS framework: 

- _Compression:_ The data file reduces the loading time by ~10%. A probably reason
for this is that less data needs to be loaded from relatively slow SSD storage,
and so less time needs to be spent loading data.
- _Binary Property List:_ iOS provides encoders and decoders for serializing 
`Codable` objects to a property list (.plist) file format. The format supports 
encoding as XML and as binary. Using XML results in a larger file compared to 
JSON (~200MB). Binary encoding fails when the file is being read, with the
error indicating that the format does not support the hierarchical depth (object
nesting) required by the trie.

Our current approach is to experiment with a more efficient data encoding 
format.

The intention is to fill the index and array offline, then write the contents of 
the data structure to a file using a compact binary representation. The file
will be included in the application bundle, and loaded by the app at launch. 

The encoding should avoid the overhead of using the JSON file format:
- JSON encodes the names of fields and uses additional syntax to define 
structure, such as brackets, braces  and quotes. Our format should use the 
structure of the encoded objects and should not require structural syntax.
- JSON encodes numbers as a sequence of characters. Our format should encode 
numbers using their binary representation. 

---

Unit testing indicates the following:     

1. Load cities from JSON data and construct index (excluding file access).
2. Load cities and index from data using `DataCodable`.
3. Load cities and index from uncompressed file using `DataCodable`.
4. Load cities and index from lz4 compressed file using `DataCodable`.

MacBook Pro M1 iOS simulator, debug (no optimization):
1. 5.5 seconds
2. 3.3 seconds
3. 3.3 seconds 
4. 4.4 seconds

iPhone X, debug (no optimization):
1. 10.3 seconds
2. 5.5 seconds
3. 5.4 seconds
4. 9.2 seconds

iPhone X, release (fastest/smallest optimization):
1. 9.5 seconds
2. 1.2 seconds
3. 1.2 seconds
4. - not tested -

The optimised `DataCodable` format improves performance 8x. The appears to be
available almost immediately after launch. 

---
