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
