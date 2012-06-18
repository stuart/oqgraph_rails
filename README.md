= OQGraph Rails

This gem can be used with ActiveRecord to access the features of the OQGraph
MySQL plugin. 

Please take a look at the Open Query Graph engine page at http://openquery.com/products/graph-engine

This provides fast graph operations on the database. It does a similar thing to the 
acts_as_graph gem, which does all the graph work on the application server. There are 
pros and cons of both approaches, It really depends on your needs. Both libraries 
use the C++ Boost graph library at the bottom layers. OQGraph has expensive 
insert operations but is very fast at delivering the graph data and finding paths in a single SQL query.

== Concepts

The term graph we are using here is a mathematical one not a pretty picture (sorry designers). 
For more see: http://en.wikipedia.org/wiki/Graph_(mathematics) 
A graph consists of nodes (aka vertices) connected by edges (aka links, paths). 
In a directed graph an edge has a direction. That is, it has an 'from' node and and a 'to' node.
When tracing a path on the graph you can only go in the direction of the edge.
The OQGraph gem operates on directed graphs. To create a non directed graph you have to create two edges,
one each way between each node.

Edges can be assigned positive floating point values called weights. Weights default to 1.0
The weights are used in shortest path calculations, a path is shorter if the sum of weights over each edge is smaller.

== What you can do with OQGraph?

Imagine your shiny new social networking app, FarceBook.
You have lots and lots of users each with several friends. How do you find the friends of friends?
Or even the friends of friends of friends...right up to the six degrees of separation perhaps?

Well you can do it, with some really slow and nasty SQL queries. Relational databases are good at set
based queries but no good at graph or tree based queries. The OQGraph engine is good at graph based queries, 
it enables you in one simple SQL query to find all friends of friends. 
Do this: 
    user.reachable
If you really want to you can rename the reachable method so you can do this in your User model:
    alias :friends, :reachable
Then I can call: 
    user.friends
and I get the whole tree of friends of friends etc...
             
Imagine you have a maze to solve. With OQGraph the solution is as simple as: start_cell.shortest_path_to(finish_cell).
See the demo code at http://github.com/stuart/acts_as_oqgraph_demo

It's good for representing tree structures, networks, routes between cities etc.

== Usage

Use the generators to create your skeleton node and edge classes.
  
  rails g oqgraph

This will create a node and an edge model as well as a migration to
create the edge model's table.

A node model should look like this:

  class Foo < ActiveRecord::Base
    include OQGraph::Node
  end

An edge model should look like this:

  class FooEdge < ActiveRecord::Base
    include OQGraph::Edge
  end
  
The edge model schema should be like this:

    create_table :foo_edges do |t|
        t.integer :from_id
        t.integer :to_id
        t.float   :weight, :limit => 25
    end
    
== Setup

This gem requires the use of MySQL or MariaDB with the OQGraph engine plugin.
For details of this see: http://openquery.com/products/graph-engine

You should be able also to extend the edge and node models as you wish.
The gem will automatically create the OQgraph table and the associations to it from your node model.

The associations are:
  node_model.outgoing_edges
  node_model.incoming_edges
  node_model.outgoing_nodes
  node_model.incoming_nodes
  edge_model.to
  edge_model.from

= Examples of Use

=== Creating edges:
 foo.create_edge_to(bar)
 foo.create_edge_to_and_from(bar)

Edge creation using ActiveRecord associations: 
 foo.outgoing_nodes << bar
or equivalently:
  bar.incoming_nodes << foo
At the moment you cannot add weights to edges with this style of notation.

Create a edge with weight:
 bar.create_edge_to(baz, 2.0)
 
Removing a edge:
 foo.remove_edge_to(bar)
 foo.remove_edge_from(bar)
Note that these calls remove ALL edges to bar from foo

=== Examining edges: 

What nodes point to this one?
Gives us an array of nodes that are connected to this one in the inward (from) direction.
Includes the node calling the method.
 foo.originating
 bar.originating?(baz)

What nodes can I reach from this one?
Gives us an array of nodes that are connected to this one in the outward (to) direction.
Includes the node calling the method.
 bar.reachable
 foo.reachable?(baz)

=== Path Finding:
  foo.shortest_path_to(baz)
   returns [foo, bar,baz]
  
  The shortest path to can take a :method which can either be :dijikstra (the default)
  or :breadth_first. The breadth first method does not take weights into account.
  It is faster in some cases.
  
  foo.shortest_path_to(baz, :method => :breadth_first)

All these methods return the node object with an additional weight field.
This enables you to query the weights associated with the edges found.

== Behind the Scenes

The OQGraph table will also get created if it does not exist. The OQGraph table is volatile, it holds data in 
memory only. The table structure is not volatile and gets stored in the db. 
When your application starts up it will put all the edges into the graph table and update them as
they are created, deleted or modified. This could slow things down at startup but caching classes in production
means it does not happen on every request. The graph table is only rewritten now when the DB has been restarted.
You can use this code to force the graph to be rebuilt:
  NodeModel.rebuild_graph

== How fast is it?
I've tested with an application with 10000 nodes and 0 to 9 links from each.

For a node connected to most of the network finding all reachable nodes averages at about 300ms.
This is strongly dependent on how well connected the graph is.

To find shortest paths between nodes takes about 5 to 10ms per request.
Here's an example request: 
  Processing OqgraphUsersController#show_path (for 127.0.0.1 at 2010-07-21 17:09:59) [GET]
  Parameters: {"id"=>"223", "other_id"=>"2333"}
    OqgraphUser Load (0.3ms)   SELECT * FROM `oqgraph_users` WHERE (`oqgraph_users`.`id` = 223) 
    OqgraphUser Load (0.1ms)   SELECT * FROM `oqgraph_users` WHERE (`oqgraph_users`.`id` = 2333) 
    OqgraphUser Load (2.2ms)   SELECT oqgraph_users.id,oqgraph_users.first_name,oqgraph_users.last_name, oqgraph_user_oqgraph.weight FROM oqgraph_user_oqgraph     JOIN oqgraph_users ON (linkid=id) WHERE latch = 1 AND origid = 223 AND destid = 2333
    ORDER BY seq;     

  Rendering oqgraph_users/show_path
  Completed in 6ms (View: 2, DB: 3) | 200 OK [http://localhost/oqgraph_users/223/path_to/2333]

Of course YMMV.

== Hairy bits, bugs and gotchas

To keep the oqgraph table up to date the edge model copies all of it records in when first instantiated.
This means that on first startup the app can be slow to respond until the whole graph has been written.
This should not need to happen again unless the DB is restarted. You can get the MySQL server to update the graph
by using the --init-file=<SQLfile> option in my.cnf with the appropriate SQL in it.

I've encountered a bug where the oqgraph table occasionally needs to be dropped and rebuilt. It's being tracked down.
If you are not getting any results from the oqgraph table try dropping it and restarting the app.

I'm working on a way to tell if the oqgraph table is stale other than by the current count of rows. Suggestions would be welcome.

Copyright (c) 2010 - 2012 Stuart Coyle, released under the MIT license
