# SwiftPack

## Overview

SwiftPack encodes and decodes data structures to and from a binary representation that provides higher IO thoughput and smaller data sizes compared to JSON.

Features include:
- Supports native Swift data types: Optionals, Boolean, Int/UInt 8, 16,32, and 64, Float, Double, Data, String, Array, Dictionary.
- Supports variable-length encoding for integers of up to 64 bits.

## Installation

[TODO]

## Usage

[TODO]

## Background

I created SwiftPack as an "extra credit" for a take-home assessment for a job I was asked to apply for in June 2022.
I ended up not taking the job for various reasons, and as this code is not subject to NDA, I decided to release it for educational purposes and reference for future job applications. 
 
The requirement of the assessment was to load a 19MB JSON file containing 200,000 cities, and then provide functionality for searching for cities. 
I first tried using `JSONDecoder` which is the obvious choice for decoding JSON data in iOS, however I soon noticed that loading the data was unacceptably slow, taking around 11 seconds on my iPhone X. 
For the assessment I wanted to make a good impression, so after I had completed all of the other requirements and with a couple of days to spare before the deadline, I set about finding ways to improvde loading performance.  

I had worked on a similar problem before in 2019/2020, when an app I had built had a new requirement where it needed to load hundreds of thousands of records from a backend API and save the data to a local database.  
While looking for solutions I investigated various ways of encoding and parsing data, and one of the encoding schemes I looked at was Google ProtoBufs. 
I recalled that protobufs was efficient at loading data, and in that case it was about ten times faster compared to JSON.

An obvious solution for this sort of problem would have been to pre-populate an SQLite database with the data and embed it in the app bundle.
The assessment did allow the data to be processed to improve performance, but forbase using any third party solutions, including databases.

I decided to try implement my own data encoding based on the same concept as protobufs.
I did not refer to the protobufs specification while implementing SwiftPack, and only relied on my prior experience with the format.
As a result, there are many differences between SwiftPack and protobufs.

My reasoning as that better performance should be achievable just by reducing the amount of data that the parser would need to process:
1. Delimiters and other formatting characters could be eliminated. The structure would be defined by the encoder and decoder.
2. Numbers could be stored as integers rather than series of characters, making decoding faster, and using less storage space.
3. Redundant field names could be eliminated.
4. Smaller data would mean less IO from the relatively slow SSD, which could improve performance overall. 

Creating the encoding was relatively straightforward, but achieving the desired performance was more challenging.
In the end two "breakthroughs" improvided performance to the range where the decoder out-performed the built-in JSONDecoder:
1. Encoding simple data as unsigned integers. All other simple types such as signed integers, Booleans, floats, and doubles are encoded as unsigned integers.  
2. Mapping data directly to pointers. Encoding simple data as integers meant that values could be mapped directly to pointers without needing to copy memory.
3. Supporting a variable-length integer type. This is mainly used to encode lengths of arrays, so that small arrays can use fewer bytes, while still being able to support large arrays when needed. 

I knew about variable length integers from my experience using protobufs but underestimated their impact on performance.
As a result of these changes, the data file size reduced from 19MB to just 9MB, app loading time improved from 11 seconds to just 1 second.
