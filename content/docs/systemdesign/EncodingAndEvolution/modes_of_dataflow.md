# Modes of Dataflow
Illurstrate more about who encodes data and who decodes it.

## Daraflow through Databases
* Store someting in the database as sending a message to your future self
* Common for several different processes to be accessing a db at the sametime
  * it's likely that some processes accessing the database will be running newer code and some will be running older code.
    * Forward compatibility required for db: value in the db may be written by a newer version of the code and subsequently read by an older version of the code that is still running.
    * Similar backward compatibility is required.
    * **there is an additional snag**
      * add a field to a record schema -> the newer code writes a value for that new field to the database -> subsequently, an older version of the code(which does not know about the new field) reads the record, updates it & writes it back-> **the desirable behavior is usually for the old code to keep the new field intact even though it could not be interpreted**
        * aviod the unknown field be lost in the translation process
### Different values written at different times
* data outlives code:While code is updated often, some data in your DB might be years old.
* Rewriting(migrating)data into a new schema is certainly possible, but it's expensive on large dataset
  * so most db avoid it if possible
  * Most relational db allow simple schema changes(e.g. adding a new column with a null default value)
    * when an old row is readm the db fills in nulls for any columns that are missing from the encoded data on the disk
* Schema evolution allows the entire db to appear as if it was encoded with a single schema even though the underlying storage may contain records encoded with **various historical versions of the schema**

## Dataflow Through Services: Rest and RPC
* The most common arrangement: clients and servers
  * servers expose an API over the newwork
  * clients can connect to the servers to make request to that API
  * the API exposed by the server is known as a service

* A server can itself be a cliennt to another service
  * ofen used to decompose a larger applicaton into smaller services by area of funtionalitu
  * this way of building applications called **service oriented architectuure(SOA)**/**microservices architecture**
  * Expect old and new versions of servers and clients to be running at the same time -> data encoding used by servers and clients must be compatible across versions of the service API

### Web services
* Using HTTP as underlying protocol for talking to service
* there are 2 popular approaches to web services
  * Rest
    * emphasizes simple data formats
    * popularity on the context of cross-organizational service integration
    * often assoicated with microservices
  * Soap
    * Web services description language/WSDL
    * useful in statically typed programming langages

### The problems with remote procedure calls(RPC)
* Remote procedure call(RPC): Make a request to a remote nework service look the same as calling a function or method in your programming language within the same process
* A network request is very different from a local function call
  * A network request is unpredicatable(e.g. request/response may be lost) while a local function call is  either sucess of fails
  * A local function call either return a result, throw an exception or never returns while  network request has another possible outcome - return without a result due to a timeout
  * if you retry a failed network request, it could happen that the request are actually getting through and only the responnses are lost
  * A network request is much slower than a function call and its latency is also wildly variable
  * when making network request, all those parameters need to be encoded into a sequence of bytes that can be sent over the network
  * the client and service may be implemented in different programming languages so RPC framework must translate datypes from one language into another

### Current directions for RPC
* service discovery - allowing a client to find out at which IP address and port number it can find a particular service.
* RPC protocoals with a binary encoding format provides bterrer performance than something generic like JSON over REST
* RPC framework is on requests between services owned by the smae organization typically within same datacenter