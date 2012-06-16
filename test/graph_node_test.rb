require 'test_helper'
require 'node'

class TestNode < ActiveRecord::Base
  include OQGraph::Node
  
end

class TestNodeEdge < ActiveRecord::Base
  extend OQGraph::EdgeClassMethods
  include OQGraph::EdgeInstanceMethods
  
  after_create  :add_to_graph
  after_destroy :remove_from_graph
  after_update  :update_graph
end

class GraphNodeTest < ActiveSupport::TestCase
  def setup
    ActiveRecord::Base.establish_connection(
        :adapter  => "mysql2",
        :host     => "localhost",
        :username => "root",
        :password => "",
        :database => "test"
      )
    
    ActiveRecord::Base.connection.execute("CREATE TABLE IF NOT EXISTS test_nodes(id INTEGER DEFAULT NULL AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255) );")
    ActiveRecord::Base.connection.execute("CREATE TABLE IF NOT EXISTS test_node_edges(id INTEGER DEFAULT NULL AUTO_INCREMENT PRIMARY KEY, from_id INTEGER, to_id INTEGER, weight DOUBLE);")
    TestNodeEdge.create_graph_table
  end
  
  def teardown
    ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS test_nodes;")
    ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS test_node_edges;")
    ActiveRecord::Base.connection.execute("DELETE FROM test_node_edge_oqgraph;")
  end
  
  test "I can connect two nodes" do
    node_1 = TestNode.new
    node_2 = TestNode.new
    node_1.connect_to node_2
    assert_includes node_2, node_1.outgoing_nodes
  end
end