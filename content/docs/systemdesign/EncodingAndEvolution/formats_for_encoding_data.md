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
   1. when old code(which does not know about the new tag numbers you added) tries to read data written by new code, including a new field with a tag number it does not recognize --> it caan simply ignore that field
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

## Avro
* Has two schema languages about the structure of the data being encoded
  * Avro intended fpr human editing
  * based on JSON which is more easily machine-readable
* there is nothing to identify fields or their types
  * to parse the binary data, need to go through the fields in the order that they appear in the schema 
  * and then use the schema to tell the datatype of each field.
  * the binary data can only be decoded correrctly if the code reading the data is using **exact same schema** as the code tha wrote the data

### The witer's schema and the reade's schema
* writer's schema: encode the data using whatever version of the schema it knons about
* reader's schema: decode the satta
* the writer's schema don't have to be the same - need to be compatible
  * e.g. schemas do not have to be in the same order
* If the code reading the data encounters a field that appears in the writer's schema but not in the reader's schema -> just ignored it
* If the code reading data expecting some field but the writer's schema does not contain a field of that name -> filled with a default value declared in the reader's schema

### Schema evolution rules
* Default value is necessary for maintaing the forward compatibity and backward compatibility
* In some programming languages, null is an acceptable default value for any variable
  * but this is not the case in avro
    * if you want to allow a field to be null, you have to use a union type -> e.g. {null long, string} indicates that field can be number, string or nu,
      * it's a little bit verbose but it helps prevent bugs by being explicit about what can and cannot be null

### What's the writer's schema
Avro's use case

#### Large file with lots of records
* Especially in the context of Hadoop - for storing a large file containing millions of records, all encoded with the same schema.
* the writer of that file can just indicate the writer's schema at the beginning of the file

#### Database with individually written records
* In db, different records may be written at the different points in time using different writer's schema
  * the simplest solution for it: 
    * include a version number at the begining of every encoded record
    * keep a list of schema versions in db
    * A reader can fetch a record -> extract the version number -> featch writer's schema for the version number from the db
#### Sending records over a network connection
* Two processes are communuicating over a bidirectional network connection -> negotiate the schema version on connection setup and then use that schema for the lifetime of the connection.(e.g. rpc, rest API)

## Dynamically generated schemas
* Advantage of the Avro's approach - does not contain any tag numbers
  * Friendlier to dynamically generated schemas
    * Have a relational db whose contents we want to dump to a file
    * using Avro, it can be easuly generate an avro schema and encode it using that schema, then dumping it into Avro obhect container file
    * Generate a record schema for each db table -> each column becomes a field in that record -> the column name in the db maps to the field name in Avro
    * If db schema changess -> genrate a new schema from the updated db schema & export data in the new avro schema 
      * since the fields are identified by name,  the updated writer's schema can stil be matched up with the old reader's schema

* However, if using the protocol buffers/thrift for the same example above
  * the field tags would likely have to be assigned by hand/or some automation scripts which need to carefully handled
    * **everytime the db schema changes, the mapping from db column names to the field tags need to be updated**

## Code generation and dynamically typed languages
* Thrift/Protocol Buffers
  * generate code that implements this schema in a programming language
  * it is useful in a statically typed languages e.g. java, C+ or C#(with the compilation step)
    * allows efficient in memory structures to be used for decoded data
    * allows type checking and autocompletion in IDEs whien writing programs that acchess the data structure 
  * for dynamically typed programming languages (e.g. js, Ruby, Python) -> meanless for generating code because of no compilation type

* Avro provides optional code generation for code generation because it works well without any code generation
* The schema is a self-describing since it contails all the necessary metadata
  * especially usefil in conjunction with dynamically typed data processing languages
