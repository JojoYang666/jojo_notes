# Leaders and Followers

## Leader-based replication/master-slave replication
* client sends request to the leader which first writes the new data to its local storage
* Other replicas known as *followers*
  * whenever the leader writes the new data to its local storage -> sends the data change to all of its followers as part of a replication log
  * each replica take the log and write it to the local storage
  * when client want to read from the db, it can either query the leader or any of followers. However, writes are only accepted on the leader.

## Synchronnous vs Asynchronous Replication
### Synchronnous
the leader waits until followers confirmed that it received the write before reporting success to the user and before making the write visible to other clients

* the follower is guaranteed to have an up-to-date copy of data that is consistent with the leader

### Asynchronous
leader sends the message but does not wait for a response from the follower

* Normally the replication is pretty fast but there is no guarantee of how long it might take(e.g. network failure issues might happen)

### Semi-synchronous
If the synchronous follower becomes unavailable or slow, one of the asynchronous followers is made synchronous

## Setting Up New Followers
* take a consistent snapshot of the leader's database at some point in time
* copy the snapshot to the new follower node
* the follower connects to the leader and requires all the data changes that have happened since the snapshot was taken.
* when the follower has processed the backlog of data changes since the snapshot, it can now continue to process data changes from the leader as they happen

## Handling Node Outages

### Follower failure" catch-up recovery
* On local disk, each follower keeps a log of the data changes it has received from the leader
* when error happened, the follower can easily recovere from the log and coonect to the leader and request all the data changes that occurred during the time when the follower was disconnected.

### Leader failure: Failover

The way of the automatic failover process as below:
* Determining that the leader has failed
  * there is no foolproof way of detecting what has gone wrong
  * most systems simply use a timeout
    * nodes frequently bounce message back and forth between each other and if a node does not respond for some period of time (e.g. 30s), it's assumed to be dead
* Choosing a new leader
  * either be done through an election process - the leader is chosen by a majority of the remaining replicas
  * a new leader could be appointed by a previously elected *controller node*
* Reconfiguring the system to use the new leader
  * clients now need to send their wirte requests to the new leader
  * The system needs to ensure that the old leader becomes a follower and recognizes the new leader


#### Failover is fraught with things that can go wrong
* If the asynchronous replication is used, the new leader may not have received all the writes from the old leader before it failed.
  * If the former leader rejoins the cluster after the new leader has been chosen -> the new leader may have received conflicting writes in the meantime(confilcts wirtes which did not reciived before as a follower)
  * the common solution: the old leader's unreplicated writes to simply be discarded, which may violate clients' durability expectations
* Discarding writes is especially dangerous(e.g. private data disclosure) if ospther storage systems outside of the db need to be coordinated with the db contents.
* split brain: two nodes both believe that they are the leader
* right timeout before the leader is declared dead
  * longer timeout means a longer time to recovery where the leader fails
  * short timeout -> unnecessary failovers
    * if the system is already struggling with high load/network problems. unnecessary failovers makes the situation worse

For this reason, some operations teams prefer to perform failovers manually even if the software supports automatic failover

## Implementation of Replication Logs
### Statement-based replication
The leader logs every write request that it executes ans sends that statement log to its followers. -> each follower parses and executes that sql statement as if it had been received from a client. This approach to replication can break down
* Any statment that calls nondeterministic function(e.g. now()) is likely to generate a differrent value on each replica
* if statements depend on the existing data in the db, they must be executed in exactly the same order on each replica. -> this can be limiting when there are multiple concurrently executing transactions
* statements that have side effects may result in different side effect occurring on each replica unless the side effects are absolutely deterministic


### Write-ahead log(WAL shipping)
* the log is an **append-only sequence** of bytes containing all writes to the database
* use the same log to build a replica on another node
  * besides writing the log to disk,  the leader also sends it across the network to its followers
  * when the follower processes this log, it builds a copy of the exact same data structure s as found on the leader
* the disadvantage: 
  * the log describes the data on a very low level(details of which bytes in which disk blocks)
  * replication closely coupled to the storage engine
  * if the db changes its storage format from one version to another -> not possible to run different versions of the datavase software on the leader and the follower
    * A big operational impact
      * **if the replication protocol allows the follower to use a newer software version than the leader -> we can perform 0-downtime upgrade of the database software by first upgrading the followers and then performing a failover to make one of upgraded nodes the new leader**

### Logical(row-based) log replication
logical log: a sequence of records describing writes to database tables at the granularity of a row which is distinguished from the storage engine's data representation.
* For an inserted row, the log contains the new values of all columns.
* For a deleted row, the log contains enough information to uniquely identify the row that was deleted.
* For an updated row, the log contains enough information to uniqurely identify the updated row, and the new values of all columns.

### Trigger-based Replication
* Used for more flexibility requirement - e.g. just want to duplicate one kind of data
* A trigger - register custom application code that is automatically executed when a data change occurs in the database system
* the trigger has the opportunity to log this change into a seperate table from which it can be read by an external process.
* the external process can then apply any necessary application logic and replicate the data change to another system.
* Has greater overheads than other replication methods and is more prone to bugs and limitations than the db's built in replication. but it's useful due to its flexibility