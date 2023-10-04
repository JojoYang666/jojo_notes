# Formats for Encoding Data

Working with data in 2 different representations:
* Memory: data is kept in obkects, structs, list, etc which are optimized for effiicient access and manipulation by the CPU(typically using pointers)
* Write data to a file or send it over the network -> encode it as some kind of self-contained sequence of bytes

Thus: 
1. encoding/serialization/marshalling --> in-memory representation to a byte sequence
2. decoding/parsing/deserialization/unmarshalling --> byte sequence -> in-memory representation
