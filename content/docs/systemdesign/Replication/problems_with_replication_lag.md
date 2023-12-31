# Problems with Replication Lag
* Leader-based replication requires all writes to go through a single node
* Read-only queries can go to any replica
* For workloads that consist of mostly reads and only a small percentage of writes(read-scaling architetecture)
  * create many followers and distribute the read requests across those follower 
  * Only realistically works with **asychronous replication**
    * unifortunately, reading from an asynchronous follower -> outdated information may be seen.
    * but eventually can update to date when there is no more writing coming into
      * this is called *replication lag* - maty be only a fraction of a second and not practice
        * if the system is operating near capacity or if there is a problem in the network- the lag can easily increase to several seconds or even minutes.

there are several real problems listed below when replication lag happens.

## Reading Your Own Writes
One popular approach: Let user submit some data and then review what they have submitted - when new data is submitted, it must be sent to the leader; when the user views the data, it can be read from the follower.

### read-after-write consistency
* With asynchronous replication - if the user views the data shortly after making a write, the new data may not yet have reached the replica -> to the user, it looks as though the data they submitted was lost
* To solve it, need **read-after-write consistency**. The possible solutions listed below
  * Reading something that the user may have modified, read it from the leader. Otherwise, read it from follower.
    * Come up some criteria that we can know data may modeified without actually querying it
      * e.g. always read the user's own profile from the leader and any other users' profiles from the follower for the social media
  * When most things in the application are potentially editable by the user
    * e.g. Track the time of the last update and for one minute after the last update, make all reads from the leader
      * can also monitor the replication lag on the follower and prevent any queries on any follower that is more than one minute behind the leader.
  * the client can also remember the timestamp of its most recent write -> the systen can ensure that the replica serving any reads for that user reflects updates at least until that timestamp.
    * the timestamp could be *logical timestamp* - somthing that indicates ordering of writes e.g. log sequence number or actual system clock
    * if the replicas are distributed across multiple datacenters - additional complexity needed ->any requests needs to be served by the leader must be routed to the datacenter that contains the leader


### Cross device read-after-write consistency
Enters some information on one device then views it on another device. Additional issues considered below
* Approaches that require remembering the timestamp of the user's last update become more difficult - the metadat will need to be centralized
* if your replicas are distributed across different datacenters, there is no guarantee that connections from different devices will be routed to the same datacenter
  * if your approach requires reading from the leader, you may first need to route requests from all of a user's devices to the same datacenter.

### Monotonic Read
User to see things *moving backward in time* which happens if user makes several reads from different replicas

* Monotonic reads only menas that if one user makes several reads in sequence,  they will not see time go backward
  * e.g. replica can be chosen based on a hash of the user ID rather than randomly

### Consistent Prefix Reads
Consisten prefix reads guarantee that if a sequence of writes happens in a certain order, then anyone reading those writes will see them appear in the same order

## Solution for Replication Lag
* Worth thinking about how the application behaves if the replication lag increases to serveral minutes or even hours