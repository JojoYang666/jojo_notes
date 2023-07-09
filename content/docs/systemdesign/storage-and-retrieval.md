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
## Markdown content
[Looking up a key using a B-tree index](../images/looking_up_a_key_using_b_tree.png)
{{< /expand >}}
