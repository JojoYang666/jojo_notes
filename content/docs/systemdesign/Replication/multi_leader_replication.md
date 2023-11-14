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

## Handling Write Conflicts