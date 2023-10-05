# Formats for Encoding Data

Working with data in 2 different representations:
* Memory: data is kept in obkects, structs, list, etc which are optimized for effiicient access and manipulation by the CPU(typically using pointers)
* Write data to a file or send it over the network -> encode it as some kind of self-contained sequence of bytes

Thus: 
1. encoding/serialization/marshalling --> in-memory representation to a byte sequence
2. decoding/parsing/deserialization/unmarshalling --> byte sequence -> in-memory representation

## Language-specific Formats

Using programming languages's built-in support for encoding. Problems as listed below:
* Reading data in another language is very difficult
* Security problems since decoding process needs to be able to instantiate arbitrary classes which attacker can execute arbitrary code remotely
* Version data
* Efficiency

**Bad idea to use language built-in encoding for anything other than very transient purposes.**

### Binary encoding
Take JSON format as an example which need a few bytes
{
    "userName": "Martin",
    "favoirateNumber": 1234
    "interests": ["daydreaming", "hacking]
}
* first byte indicates what follows is an object with x fields
* second byte indicaes that what follows is a string with x bytes long
* the next x bytes are the field name in ASCII
* the next y bytes encode the 6 letters - Martin

The binary encoding is 66 bytes long which is only a little less than the 81 bytes taken by the textual JSON encoding.