require 'test_helper'
#require 'active_support/testing/performance'

class TestNode < ActiveRecord::Base
  include OQGraph::Node
end

class TestNodeEdge < ActiveRecord::Base
  include OQGraph::Edge
end

class PerformanceTest < ActiveSupport::TestCase
#include ActiveSupport::Testing::Performance
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
    
    puts "Creating 10000 test nodes"
    @test_nodes = [1..10000].map{|i| TestNode.create(:name => "node#{i}")}
  end

  def teardown
    ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS test_nodes;")
    ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS test_node_edges;")
    ActiveRecord::Base.connection.execute("DELETE FROM test_node_oqgraph;")
  end

  test "joining nodes" do
    @test_nodes.each do |node|
      
    end
  end

  test "finding the shortest path" do
  end

  test "finding connected nodes" do
  end

  test "removing connections" do
  end

end