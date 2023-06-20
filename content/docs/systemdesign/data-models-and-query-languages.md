# Relational Model
* Relational databases: transaction processing or batch processing
* Goal: hide the implementation detail behind a cleaner interface
* `foreign key` for join
* Pros: fit for joins - many to one and many to many relationships
* Schema-on-write - schema explicit and db ebsures data conforms to it
    * Migration needed whe schema changed
        * migrate at one time
        * Set null for the new schema and fill/update it at the read time

# Document Model(No sql)
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
    * one to many relationships
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

## Data locality for queries
* Document is usually stored as a single continuous string
* `Storage locality`: performance happened when the application need to access the whole document(e.g. render it on a web page)
* Updates to a document, the entire document needs to be rewritten in general -> tips: **keep documents fairly small and avoid writes that increase the size of a document**
* locality is not limited to the document model and used in the relational model as well

# Query
## Query Languages for Data

### Declarative query
* Sql style language
* Focus on how you want the data to be transformed(e,g, sorted, grouped) not how to achieve that goal
* It's possible for the db to introduce performance improvements without requiring any changes to the query(**query optimizer**)
* Lend themselves to parallel execution
* web: e.g. xml, css

### Imperative language/query
* programming languages specify the operation
* Tell the computer to perform certain operations in a certain order
* hard to parallelize across multiple cores  and muvhines since of the ordered specified by the language
* web: e.g. js to do the styling operations                                                                                                                                          

### Map reduce query
* neither declarative query language nor a fully imperative query API, but sinewhere in between
* map and reduce functions must be the pure functions
    * they only use the data that us passed to them as input
    * they cannot perform additional db queries
    * they must not have any side effects
* fairly low level programming model for distributed execution on a cluster of machines

# Graph-Like Data Models(No sql)
* Graphs are not limited to homogeneous(similar kind or nature) data. It aslo has the equally powerful use of graphs to provide a consistent way of storing compeletely different types of objects in a single db

## Property Graphs
Each vertex consists of
* A unique identifier
* A set of outgoing edges
* A set of incoming edges
* **A collection of properties(key-valure pairs)**

Each edge consists of
* A unique identifier
* the tail vertex
* the head vertex
* A label to describe the kind of **relationship** between two vertices
* **A collection of properties(key-valure pairs)**

Graph can be considered as two relation tables - one for vertices and one for edges

By using different labels for different kinds of relationships
* store different kinds of information in a single graph
* Maintaing a clean data model
* a great deal of flexibility for data modeling and good for **evolvability**
  
## Query
### Cypher query language
`Cypher` is a **delcarative** language for property graphs(created for Neo4j graph db)

### Graph queries in sql
* Traversing a variable number of edges before find the vertex you are looking for is needed for graph query
* `Recursive common table experssions` - `WITH RECURSIVE` syntax
  * variable-length traversal paths

### Triple-Stores and SPAROL

## Triple store
1. stored in the form of simple three-part statements: (subject predicate, object)
2. `subject` is equivalent to a vertex in a graph
3. `object` is one of two things in the graph:
   1. A value in a primitive datatype -> equivalent to the key and value of a property on the subject vertex
   2. another vertex in the graph --> predicate is an edge in the graph

## The semantic web
idea of with information as machine-readable data for computers to read

### the RDF data model
1. RDF(resource description framework):
* Allowing data from different websites to be autimatically combined into a web of data
* Designed for internet-wide data exchage
* (subject, predicate, object) -- often URIs(words with the url prefix as namespace)

2. SPARQL query language
   1. `SPARQL`: query languagefor triple-stores using the RDF data model

## Graph db vs Network Model
1. Network model(CODASYL): a schema required for specifying the record type to be nested within which other record type, while graph db does not have such restriction
2. Network model(CODASYL): reach particular record requiring tranverse one of the access path, while  graph can be refer to any vertex by id
3. Network model(CODASYL): children of a record were an ordered set, while graph db does not have such restriction
4. Network model(CODASYL): queries are imperative, diffcult to write and easily broken by changes in the schema

## The Foundation: datalog
1. older language
2. foundation of later query languages build upon
3. In datalog, define `rules` that tell db about the new predicates and execute subsequent rules when a rule is matched
4. can be combined and reused in different queries
 