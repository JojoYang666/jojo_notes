<!-- ---
title: "Storage and Retrieval"
date: 2023-06-19T22:13:18-07:00
draft: true
--- -->

# Data Structures that Power Your Database
* Index: To keep some additional metadata on the side, which acts as a signpost and help to locate the additional metadata on the side.
* Trade off in the storage systems: well-chosen indexes speed up read queries but every index slows down writes
* Write --> append on the file

## Hash Indexes

### In memory hash map(e.g. bitcask)
* Key is mapped to a **byte offset** in the data file
* High performance on both write and read --> keys fit in the available RAM
* Fit for: value for each key is updated frequently
* Avioid running out of disk space if only append to a file for writing operation(insert & update)
  * Break the log into segments of a certain size by closing a segment file when it reaches a certain size
  * Perform compaction on the segments in a background thread
  
#### Possible issues on implementaion of the segments and compaction
* File format
  * Use a binary format that first encodes the length of a string in bytes, followed by the raw string(without need for escaping)

* Deleting records
  * Delete a key-value pair, append a spection deletion record to the data file(called 'tombstome')
  * Merge happened --> discard any previous values for the deleted key

* Crash recovery
  * restore from the segement file --> but pretty slow if the segment files are large
  * Speed up by storing a snapshot of each segment's hash map on disk

* Partially written records
  * Appebding record did not finsh when crash happened
  * using `checksums` -> to detect partially written records and ignore it

* Concurrency control
  * Single thread for the writing while read can be concurrently by multiple threads

#### Pros and cons for the appebd-only design for the hash table index
* Pros
  * Sequential write operations faster than random writes
  * Concurrency and crash recovery simpler
  * Merging old segemnts avoids the problem of data files getting fragmented over time

* Cons
  * Hash table must fit in memory
  * Range queries are not efficient - e.g. scaning over all keys between kitty00000 and kitty99999

## SSTables and LSM-Trees

### SSTables
* Definiation: the sequence pf key-value pairs is **sorted by key**
* Pros
  * Merging segment is simple and efficient(merge-sort)
  * No longer need to keep an index of all keys in memory to find a particular key in the file
    * Keep an in-memory index with offsets for **some of keys** - sparse since key is sorted
    * Sorted segment on the disk can be compressed before writing into the disk(save disk space & reduce the I/O bandwidth)

#### Constructing and maintaing SSTables
* Maintaing it in the memory with tree structure ->(e.g. red-black tree or AVL tree)
  * insert it in any order and read them in a sorted order

* How it works
  * write comes in --> add it into an in-memory balanced tree data structure(called memtable)
  * memtable gets bigger than threshold(a few MB) --> write into disk as SSTable
  * serve a read request --> in memotable ->most recent on-disk segment --> next older segment
  * run merging and compaction process in the background & discard overwritten or deleted values

* what happened if db crashes
  * Keep a separate log on disk to which every write is immediately appended


### LSM-Tree
* Log-Structured Merge Tree(LSM tree): keeping a cascade of SSTables that are merged in the background
* LST tree can be slow when looking up keys that do not exist in the db
  * Using **Bloom filters** to solve it - a memory-efficient data structure for approximating the contents pf a set
  * Tell you if a key is in the db - save many unnecessary disk reads for nonexistent keys

* Size-tiered compaction
  * newer and smaller SSTables are successively merged into older and larger SSTables

* Leveled compaction
  * key range is split into smaller SSTables and older data is moved into seperate levels - allow the compaction to proceed more incrementally and use less disk space


### B-Trees
The most widely ised indexing structure

* Features
  * key-value pairs sorted by key
  * break the db down into **fixed-size** blocks or pages -- traditionally 4KB in size
  * write or read one page at a time
  * page identified by address/location - write into the **disk**
  * Example
{{< expand "Example of B Trees" "..." >}}
![Looking up a key using a B-tree index](../images/looking_up_a_key_using_b_tree.png)
{{< /expand >}}

  * Most db can fit into B tree that is 3 or 4 levels deep(e.h. 4 level tree of 4KB pages with a branching factor of 500 can store up to 256 TB)

* Reliable
  * overwrite a page on disk with new data
  * crashes for the case of -> insert new data & over full,  then need to spilt page into 2 half full pages(multi steps)
  * Additional structure on disk needed: write-ahead log(WAL, redo log)
    * append-only file  - every B-tree modification must be written before it can be applied to the page of the tree it self
  * Concurrency control - solved by **latches**(lightweight locks)


* B-tree optimizations
  * Use copy-on-write scheme
    * modified page is written to a different location & a new version of the parent pages in the tree is created, pointing at the new location
    * Useful for the concurrenty control
    * Abbreviating key to save the space and increase the branching factors
      * Especially for the pages on the interior of the key
    * Additional pointers added to the tree(e.g. leaf page with pointers to their sibling)
    * Log structured ideas to reduce disk seeks

### Comparison between LST trees and B-trees
1. Write amplication: write to the db resulting in multiple writes to the disk over the course of the db's lifetime
   1. write amplication is a particulat concerns on SSDs, which can only overwrite blocks as limited number of times before wearing out
   2. write amplication a direct performance cost for a write-heavy application
2. LSM:
   1. Pros
      1. higher write throughput than B trees
      2. can be compressed better, thue produce smaller files than B trees(because of fragmentation on B trees - page split when a row cnnot fit into an existing page)
   2. Cons
      1.  compaction process can sometimes interfere with the performance of the ongoing reads and writes
          1.  explicit monitoring is needed

3. Pros of B-trees
   1. Each key exists in exactly one place in the index, wheres a log structured storage engine may have multiple copies of the same key in different segments
      1. good for offering strong transactional semantics


## Other indexing structures
Secondary indexes
  * Not unique, can be solved in the ways below
    * Making each value in the index a list of matching row identifiers
    * makeing each key unique by appending a row identifier to it

### Storing values within the index
* Value of the query key can be two things below
  * the actual vertex
  * a reference to the row stored elsewhere
    * **heap file**: the place where rows are stored
      * avoids duplicating data when multiple secondary indexes are present
      * efficient when updating value without changing key
      * will be complicated if the new valueis larger, two possible ways listed below
        * all indexes need to be updated to point at the new heap location of the record
        * forwarding pointer is left behind in the old heap location
    * **clustered index**:
      * store the indexed row directly within an index
      * why not heap file: the extra hop from the index to the heap file is too much of a performance penalty for reads
    * both clustered index and heap file can speed up reads
      * additional storage required and add overhead on writes

  * Multi-column indexes
    * Query multiple columns of a table simultaneously
    * concatenated index: combines several fields into one key -- e.g. old fashioned paper phone book
    * one use case: querying geospatial data - query map within a rectangular
      * two options
        * two dimensional location into a single number using **spacing-filing curve** 
        * R-trees -> spatial indexes
  * fuzzy search
    * aka similar search,(fault tolerant)

## Keeping everything in memory
* some Key-value stores - intended fo caching use only
  * acceptable for data to be lost if a mahinne is restarted
*  in memory db aim for durability
   *  using special hardware
   *  writing a log of changes to disk
   *  writing periodic snapshots to disk
   *  replicating the in memory state to other machines
   *  writing to disk as append only logs

* the advantage of in-memory databases
  * performance: avoid the overheads of encoding in memory data structure in a form that can be written to disk
  * providing the data models that are difficult to implement with disk-based db

## Transaction processiong or Analytics
{{< tabs "transaction_procesing" >}}

{{< tab "Data Warehousing" >}}
# Data Warehousing
* seperate database that analysts can query to their hearts content whithout affectng OLTP operations
* extracted from OLP db(using data dump or continous stream of updates)
* extract-transformed-load(etl): data from OLTP to OLAP
* can be optimized for analytic access pattern

## Stars and Snowflakes: Scchemas for analytics

* star schema/dimensional modeling
  * fact tables
  * each row in the fact table represents as an event
  * other tables called dimension tables
    * the dimensions represent: who, what, where, when, how & why of the vent
  * the fact table is in the middle & surroundd by its dimension tables -- like star

* snowflake schema
  * a variation of the star schma
  * dimensions are further broken into subdimensions
  * star schemas oftn prefrred since it's easy to work with

fact table & dimension table are often wide in general

{{< /tab >}}

{{< tab "Column-Oriented Storage" >}}

# Column-Oriented Storage
Query data with trillions of rows & pretabytes of data is challengeing

* Most OLTPm storage is laid out in a *row-oriented* fashion
  * all the value from one row of a table are stored next to each other

* column-oriented storage
  * do not store all values from one row together, but store all values from each column together instead
  * cntaining the rows in the same order

## Column Compression

### Bitmap encoding
* the number of distinct values in a column is small compared to the number of rows
* Take a column with n distinct values and turn it into n seperate bitmaps
  * one bitmap for each distinct value with one bit for each row
  * the bit is 1 if the row has that value and 0 if not
* if n is very small --> those bitmaps can be stored one bit per row
* if n is bigger, there will be lots of 0s in most of bitmaps
  * bit map can be additionally run length encoded

### Memory bandwidth and vectorized processing

* bottleneck of the data warehouse is:
  * getting data from disk into memory
  * using bandwidth from main memory into the cpu cache
  * avoiding branch mispredications
  * bubbles in the CPU instruction processing pipeline
  * making use of single-instruction–multi-data(SIMD) instructions in modern CPUs
* vertorized processing
  * a central processing unit (CPU) that implements an instruction set where its instructions are designed to operate efficiently and effectively on large one-dimensional arrays of data called vectors(compressed column data)

### Sort Order in Column Storage
* Sort rows first and then extract column storage
* sorted order will help compress data
* sort the same data in several different ways
  * Data needs to be replicated to multiple machines anyway

### Aggregation: Data Cubes and Materialized Views
* Materialized view
  * Actual copy of results from frequently used queries which have much aggregation operations
  * one special case is known as data cube / OLAP cube
  * faster to query but less flexibility
{{< /tab >}}
{{< /tabs >}}

