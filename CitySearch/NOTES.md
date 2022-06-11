#  Development Notes

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

## TODO

- Document "test" command line argument
- Use binary insertion sort when inserting characters and values into trie 
nodes to avoid having to re-sort each array when a value is inserted. 
- Localize text.
- Make search index and query case insensitive.
- Test non-latin characters (e.g. emoji)
- Logging abstration.
- Metrics.
- Keyboard avoidance for placeholders.
- Dismiss keyboard on search screen while keeping current query.
- Include country in search index.
