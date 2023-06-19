<!-- ---
title: "Data Models and Query Languages"
date: 2023-06-14T22:14:44-07:00
draft: true
--- -->
# Relational Model
* Relational databases: transaction processing or batch processing
* Goal: hide the implementation detail behind a cleaner interface
* `foreign key` for join
* Pros: fit for joins - many to one and many to many relationships
* Schema-on-write - schema explicit and db ebsures data conforms to it
    * Migration needed whe schema changed
        * migrate at one time
        * Set null for the new schema and fill/update it at the read time

# No Sql/ Document Model
* Greater scalability
* A more dynamic and experssive data mode
* `document rederence` for join
* Schema-on-read: the implicit data structure * only interpreted when data is read
    * Application code to handle the implict schema changes.
    * use case:
        * items in the collection do not all have the same structure for some reason
            * many different types of objects and it's not proactical to put each type object in its own table
            * the structure of the data is determined by external systems over which you have no control and which may change at time
* Advantage:
    * schema flexibility, better performace due to locality
    * for some applications, it is closer to the data structure used by the applicaton
    * Fit for the appilication if the data is a document-like structure(e.g. tree)
* Cons
    * bad for many to many relationships
        * since application code need to do additional work to keep denormalized(repeat) data consistent


# Object-Relational Mismatch
* Impedance mismatch: awkward translation layerß between objects in the application code and the database model of tables, rows & columns
* One to many relationship
    * can be represented on the ways below
        * Store information in the seperate tables with the foreign key
        * Allow multi-value data to be stored within a single row
        * Encode as a document and store in a txt column - but this cannot be quried
    * tree structure

* Many to one relationship / many to many relationsips
    * using the meanless ID to represent entity - key
    * hard to fit in to the document db since join is every week

# Database models
Simple initial model is `hierarchical model` which is a tree structure and fit into one to many relationship but hard for many to many relations because of joining(used in the document db more often).

## Network model(CODASYL)
* Generaliztion of the hierarchial model
* one mode/record can have multiple parents
* Good for many to one or many to many relationships
* The links between records are not foreign keys and more like the pointers in the programming language
* The only way of accessing a record: follow a path from a root record along these chains of links - called `access path`
* One data may have different access path, the head have to keep track of all different access paths
* Disadvantage
    * Hard for the querying and updating db
        * if fo noy have a path to the quired data, gave to go through a lot of handwritten db query code and rewirte it for the new access path
## The relational model
* Defined table structure to be filled information
* query Optimizer automatically decide order of the sub queries
* By declaring a new index, we can query data in new ways