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


#### Failover is fraughr with things that can go wrong
* If the asynchronous replication is used, the new leader may not have received all the writes from the old leader before it failed.
  * If the former leader rejoins the cluster after the new leader has been chosen -> the new leader may have received conflicting writes in the meantime(confilcts wirtes which did not reciived before as a follower)
  * the common solution: the old leader's unreplicated writes to simply be discarded, which may violate clients' durability expectations