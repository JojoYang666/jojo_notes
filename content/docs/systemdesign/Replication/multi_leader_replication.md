# Multi-Leader Replication
Multi-leader/Master-master configuration - each leader simultnaneously acts as a follower to other leaders

## Use Cases for Multi-Leader Replication

### Multi-datacenter operation
Within each datacenter, regular leader-follower replication is used; between datacenters, each datacenter's leader replicates its changes to the leaders in other datacenters.

Single-leader vs Multi-leader
* Performance
  * The inter-datacenter network delay is hidden from users which means the perceived performance may be better -(multi-leader)
* Tolerance of datacenter outages
* Tolerance of network problems

The big downside of the multi leader: the same data may be concurrently modified in two different datacenters and those wirte conflicts must be resolved
  * Multi-leader replication is often considered dangerous territory that should be avoided if possible

### Clients with offline operation
Multi-leader replication is appropriate - if you have an application that needs to continue to work while it is disconnected from the internet

each local device has a local db that acts as a leader which can be considered as datacenter

### Callaborative editing
make the unit of change very small and avoid locking

## Handling Write Conflicts
Wirting conflicts can happen on the Multi-leader replication

### Synchronous vs Asynchrounous Conflict Detection
* Single-leader db, the second writer will either block and wait for the first write to completer/abort the second transaction
* Multi-leader: conflict is only detected async at some time later at some point -> may too late
  * could the make the conflict detection synchronous -> however, it loses the advantage of multi-leader replication

### Conflict Avoidance
* If the application can ensure that all writes for a **particular record** go though the **same leader**, -> the conflicts cannot occur.
* Aviod conflicts is the *frequently* recommended approach
* For the application where a user can edit their own data ->from any one user's point of view -> the configuration is essentially single user
  * some times change the designated leader for a record is needed
    * conflict avoidance breaks down and have to deal with the possibility of concurrent writes on different leaders
  
### Converging toward a consistent state
All replicas must arrive at the same final value when all changes have been replicated

Conflict Resolution:
1. Give each write a uniqure ID -> ouck the write with the highest ID as the winner and throw away other wirtes
2. Give each replica a uniqure UD -> writes that originated at a higher numberred replica always take precedence over writes that origineated at a lower numbered replica
3. somehow merge the values together
4. Record the conflict in an explicit data structure that preserces all information and write application code that resolves the conflict at some later time
  
### Custom conflict resolution logic
The ocde if resolutioon logic be excuted on write/on read:

#### On writer
As soon as db detects a conflict in the log of replicated changes -> it calls the conflit handler

#### On read
conflict detected -> conficting writes stored -> multiple versions of the data are returned to the application -> user reolve and write back to the database

## Multi-Leader Replication Topologies
1. Describles the communication paths along which writes are propogated from one node to another.
2. THe most general topology is all to all
   1. Every leader sends its writes to every other leader
   2. Some network links may be faster than others with the result that some replication message may overtake others
   3. Order events correctly -> version control
3. Circular and start topologies:
   1. prevent infinite replication loops -> each node is given a uniqure identifier ->in the replication log, each write is tagged with the identifiers of all the nodes it has passed through -> when a node receives a data change that is tagged with its own identifier, that data change is ignored
   2. Problem: if just one node fails, it interrupt the flow of replication messages between other nodes, causing them to be unable to communicate until the node is fixed
4. Using system with multi leader replication- > worh being aware of these issues, read doc, thoroughly testing db

# Leaderless Replication
1. Client directly sends its writes to several replicas, while, a coordinator node does this on behalf of the client
2. the coordinator does not enforce a particular ordering of writes

## Writing to the db when a node is down
1. Sending wirte request to multiple nodes in parallel as long as some of nodes hanles write request sucessfully. We are good
2. Read request: 
   1. read request are also sent to several nodes in parallel
   2. version number are used to determine which value is newer

### Read repair and anti-entropy
#### Read repair
* Detect any stale responses when sending read request
* Works well for values that are frequently read.

#### Anti-entropy process
Background process that consistantly looks for differences in the data between replicas and copies any missing data from one replica to another

### Quorums for reading and writing
1. n replicas, w nodes to be considered **successful** for write request, query at least r nodes for each read
   1. w + r > n -> get an up to date value when reading
   2. common choice: n -> odd number(typically 3 or 5), w = r = (n+1)/2
   3. Workload with few writes and many reads -> benefit from setting w = n & r = 1
2. w, r determine how many nodes we wait for/how many of n nodes need to report success before we consider the read/write to be successful.

#### Limitations of Quorum Consistency
Smaller w and r which makes w+ r < n:
* allows lower latency and higher availability even though more likely to read stale values

Even with w+r > n, lokelu to be edfe cases where stale values are retured:
* *sloppy quorum is used*, no guaranteed overlap between the r nodes and the w nodes
* two writes occur concurrently -> not clear which one happened first
* wirte happens concuurrently with read -> wirte may be reflected on only some of the replicas
* wirte succeeded on some replicas but failed on others & overall succeeded on fewer than w replicas -> not rolled back on the replicas where it succeeded
* node carrying a new value fails & data restored from a replica carrying an old value -> # of replicas storing the new value may fall below w -> breaking the quorum conditions
* there are some edge cases going with the timing

##### Monitoring staleness
* Leader-based replication
  *  since writes are applied to the leader and followers in the same order and each node has a position in the replication log
     *  substractinng a follower's current position from the leader's current position, -> measure the amount of replication lag
* Leaderless replication
  * difficult to measure and better to have a metric

## Sloppy Quorums and Hinted Handoff
* quorums are not as fault-tolerant - network interruption can easily cut off a client from a large number of db nodes which may make other clients fail
* sloppy quorums
  * during the network interruption, client can connect to some db nodes which is not to the node that it needs to assemble a quorum for a particular value
    * write them to some nodes that are reachable but are not among the n nodes on which the value usually lives
  * increases write availability
  * cons: even when w + r > n -> cannot guaranntee that a read of r nodes will see it until the hinted handoff has completed
  * this is an assurance of durability

## Detecting Concurrent Writes
* The last write wins(discarding concurrent writes)
  * achieves the goal of eventual convergence but at the cost of durability - drap some wirtes when concurrennt even are not concurrent(timestamp for ordering issues)
  * LWW is a poor choice when losing data is not acceptable
  * the only safe way of using a db with LWW is to ensure that a key is only written once and thereafter treated as immutable thus avoid any concurrent updates to the same key

* the "happens-before" relationship and concurrency
  * an operation A happens before another operation B if B knows about A or depends on A or builds upon A in some way
  * two operations A and B, there are 3 possibilities
    * A happened before B
    * B happened before A
    * A and B are concurrent
      * it's not necessary happens on the same time as long as there is no causal dependency between operations
