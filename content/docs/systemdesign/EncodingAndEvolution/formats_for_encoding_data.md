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

## Thrift and Protocol Buffers
* Come with a code generation tool that takes a schema definition  & produces classes that implement schema in various programming languages
* Thrift
  * BinaryProtocol
    * No field name and use field flag instead
  * CompactProtocol
    * Packing the field type & tag number into a sigle byte
    * Using variable length integers
    * Bigger numbers use more bytes
* Protocol Buffers
  * only has one binary encoding format
  * have optional & required for the field
    * No difference to how the field is encoded
    * `required` enables a run time check that fails if the field is not set

### Field tags and schema evolution
1. Field's tag cannot be changed since it will make all existing encoded data invalid
2. Forward compatibility
   1. when old code(which does not know about the new tag numbers you added) tries to read data written by new code, including a new field with a tag number it does not recognize --> it can simply ignore that field
      1.  the annotation allows the parser to determine how many bytes it needs to skip
3. backward compatibility
   1. new code can always read old data -> because the tag numbers still have the same meaning
   2. every field you add after the inital deployment of the schema must be optional or have a default value
4. Removing a field is just like adding a field
   1. only remove a field that is optional
   2. can never use the same tag number again

### Datatypes and schema evolution
* It's possible to change the datatype of a field 
  * there is a risk that values will lose precision or get truncated
* Protocol buffers - does not have a list or array datatype(using repeated instead)
  * encoding of a repeated field - the same field tag simply appears multiple times in the record
  * ok to change an optional to repeated - new code reading old data sees a list list with 0 or 1 element
  * old code reading new data sees only **the last element of the list**
* Thrift  - does not allow the same evolution from the single values to mulyi-valued as protocol buffers
  * but it has the advantage of supporting nested lists