Distributed kNN
===============


3 node types

 Each node is just a server process that takes some HTTP calls.


1. Command/Query node
	- Accepts data set command
	- Accepts point/points to test
	- Takes stream of data??
	- Maintains state of cluster, based on heartbeats
		- Extra credit: Use Raft or Paxos to make this node redundant
2. Data store nodes
	- Replicate data set?
	- Supply data to mesh nodes based on requests from Mesh
	- Heartbeat
3. Partitioned Mesh nodes
	- Calculate KNN, and then ask their neighbors for the KNN of a test point
	- Ask each data store node for data belonging to its partition
	- Heartbeat

Elixir Links:
https://hexdocs.pm/elixir/GenServer.html#content
https://github.com/elixir-lang/gen_stage
https://github.com/devinus/poolboy



Possible Implementation
-----------------------

#####Command Node
- [x] Keel Parser
  - [x] Parses Headers
  - [x] Parses Records
  - [x] Emits records with dataset as they are generated.
- [ ] Keeps track of all discoverable nodes
- [ ] Needs to maintain a map between each connected node and its "job".
	- Will rely on keel parser having already run
		- After the headers are parsed, we’ll know how many different classifications exist and can divide available nodes accordingly
	- Map needs to stay updated as nodes come up/down.
	- Should probably be kept in an ETS table outside of its local supervision tree
- [ ] Needs to implement a function that other nodes can call so that the command node can tell then who their neighbors are.
- As nodes come up/down, needs to try to evenly distribute responsibilities to them
	- E.g. assign them to be either storage nodes or mesh(partitioner) nodes
- [ ] Is responsible for opening a stream of data after nodes initially connect, splitting the data into sections, and distributing it to all connected "storage" nodes.
	- Needs to accept two sets of data, the training set and the test set

#####Storage Node
- [ ] This is a relatively dumb node
- [ ] Takes in a stream of data
- [ ] Stores data in an [ETS](http://erlang.org/doc/man/ets.html) table
- [ ] Provides API to check if items exist in it/fetch/upsert

#####Mesh (partitioner) 
- [ ] Provides implementation of local kNN function
- [ ] Asks Command Node for `node`’s neighbors, and asks them to return their local kNN as well


######Keel Header Sample

```keel
@relation iris
@attribute SepalLength real [4.3, 7.9]
@attribute SepalWidth real [2.0, 4.4]
@attribute PetalLength real [1.0, 6.9]
@attribute PetalWidth real [0.1, 2.5]
@attribute Class {Iris-setosa, Iris-versicolor, Iris-virginica}
@inputs SepalLength, SepalWidth, PetalLength, PetalWidth
@outputs Class
```
