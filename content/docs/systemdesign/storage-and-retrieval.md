---
title: "Storage and Retrieval"
date: 2023-06-19T22:13:18-07:00
draft: true
---

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

