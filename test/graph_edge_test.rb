require 'test_helper'
require 'graph_edge'

class TestModelEdge < ActiveRecord::Base
  extend OQGraph::GraphEdge
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
    @test_model_edge = TestModelEdge.create!(:from_id => 1, :to_id => 2, :weight => 1.0)
    puts "TABLES:" 
    puts ActiveRecord::Base.connection.select_values("SHOW TABLES;")
    TestModelEdge.create_graph_table
    assert_equal 1, ActiveRecord::Base.connection.select_value("SELECT count(*) FROM test_model_edge_oqgraph;")
  end
end