# Implementation of Replication Logs
## Statement-based replication
The leader logs every write request that it executes ans sends that statement log to its followers. -> each follower parses and executes that sql statement as if it had been received from a client. This approach to replication can break down
* Any statment that calls nondeterministic function(e.g. now()) is likely to generate a differrent value on each replica
* if statements depend on the existing data in the db, they must be executed in exactly the same order on each replica. -> this can be limiting when there are multiple concurrently executing transactions
* statements that have side effects may result in different side effect occurring on each replica unless the side effects are absolutely deterministic


## Write-ahead log(WAL shipping)
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