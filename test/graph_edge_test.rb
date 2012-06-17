require 'test_helper'
require 'oqgraph_rails'

class TestModelEdge < ActiveRecord::Base
    include OQGraph::Edge
end

class GraphEdgeTest < ActiveSupport::TestCase
  def setup
    ActiveRecord::Base.establish_connection(
        :adapter  => "mysql2",
        :host     => "localhost",
        :username => "root",
        :password => "",
        :database => "test"
      )
    
    ActiveRecord::Base.connection.execute("CREATE TABLE IF NOT EXISTS test_model_edges(id INTEGER DEFAULT NULL AUTO_INCREMENT PRIMARY KEY, from_id INTEGER, to_id INTEGER, weight DOUBLE);")
    TestModelEdge.create_graph_table
  end
  
  def teardown
    ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS test_model_edges;")
    ActiveRecord::Base.connection.execute("DELETE FROM test_model_edge_oqgraph;")
  end
  
  test "the oqgraph table is created" do
    assert_includes ActiveRecord::Base.connection.select_values("SHOW TABLES;"), 'test_model_edge_oqgraph'
  end
  
  test "the oqgraph is updated when there are records that need to be added" do
    test_model_edge = TestModelEdge.create!(:from_id => 1, :to_id => 2, :weight => 1.0)
    TestModelEdge.create_graph_table
    assert_equal 1, ActiveRecord::Base.connection.select_value("SELECT count(*) FROM test_model_edge_oqgraph;")
  end
  
  test "adding a new edge to graph" do
    test_model_edge = TestModelEdge.create!(:from_id => 1, :to_id => 2, :weight => 1.0)
    assert_equal 1, ActiveRecord::Base.connection.select_value("SELECT count(*) FROM test_model_edge_oqgraph;")
  end
  
  test "removing an edge from the graph" do
    test_model_edge = TestModelEdge.create!(:from_id => 1, :to_id => 2, :weight => 1.0)
    test_model_edge.destroy
    assert_equal 0, ActiveRecord::Base.connection.select_value("SELECT count(*) FROM test_model_edge_oqgraph;")
  end
  
  test "removing an edge does not remove from graph table if other edges with the same nodes exist" do
    test_model_edge = TestModelEdge.create!(:from_id => 3, :to_id => 4, :weight => 1.0)    
    test_model_edge_2 = TestModelEdge.create!(:from_id => 3, :to_id => 4, :weight => 1.0)  
    test_model_edge.destroy
    assert_equal 1, ActiveRecord::Base.connection.select_value("SELECT count(*) FROM test_model_edge_oqgraph;")
  end
  
  test "updating an edge" do
    test_model_edge = TestModelEdge.create!(:from_id => 3, :to_id => 4, :weight => 1.0)    
    test_model_edge = test_model_edge.update_attributes(:from_id => 4, :to_id => 1, :weight => 2.0)
    assert_equal 1, ActiveRecord::Base.connection.select_value("SELECT count(*) FROM test_model_edge_oqgraph WHERE origid = 4 AND destid = 1 AND weight = 2.0;")
    assert_equal 0, ActiveRecord::Base.connection.select_value("SELECT count(*) FROM test_model_edge_oqgraph WHERE origid = 3 AND destid = 4 AND weight = 1.0;")
  end
end