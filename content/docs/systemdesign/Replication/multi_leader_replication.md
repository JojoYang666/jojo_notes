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