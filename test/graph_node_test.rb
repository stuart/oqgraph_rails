require 'test_helper'
require 'node'
require 'edge'

class TestNode < ActiveRecord::Base
  include OQGraph::Node
end

class TestNodeEdge < ActiveRecord::Base
  include OQGraph::Edge
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
    
    @test_1 = TestNode.create(:name => 'a')
    @test_2 = TestNode.create(:name => 'b')
    @test_3 = TestNode.create(:name => 'c')
    @test_4 = TestNode.create(:name => 'd')
    @test_5 = TestNode.create(:name => 'e')
    @test_6 = TestNode.create(:name => 'f')
  end
  
  def teardown
    ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS test_nodes;")
    ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS test_node_edges;")
    ActiveRecord::Base.connection.execute("DELETE FROM test_node_edge_oqgraph;")
  end
  
  test "I can connect two nodes" do
    @test_1.create_edge_to @test_2
    assert_equal 1, TestNodeEdge.where(:from_id => @test_1.id, :to_id => @test_2.id, :weight => 1.0).count
    assert_includes @test_1.outgoing_nodes, @test_2
  end
  
  test "creation of edges by association" do
    @test_1.outgoing_nodes << @test_2
    assert_not_nil edge = TestNodeEdge.find(:first, :conditions => {:from_id => @test_1.id, :to_id => @test_2.id})
  end
  
  test "creation of unidirectional edges" do
    @test_1.create_edge_to_and_from(@test_2)
    assert_not_nil edge = TestNodeEdge.find(:first, :conditions => {:from_id => @test_1.id, :to_id => @test_2.id, :weight => 1.0})
    assert_not_nil edge = TestNodeEdge.find(:first, :conditions => {:from_id => @test_2.id, :to_id => @test_1.id, :weight => 1.0}) 
    assert @test_1.outgoing_nodes.include?(@test_2)
    assert @test_1.incoming_nodes.include?(@test_2)
  end
    
  test "adding of weights to edges" do
    @test_1.create_edge_to(@test_2, 2.0)
    assert_not_nil edge = TestNodeEdge.find(:first, :conditions => {:from_id => @test_1.id, :to_id => @test_2.id})
    assert edge.weight = 2.0
  end
  
  test "edge model creation creates oqgraph edge" do
    @test_1.create_edge_to(@test_2, 2.5)
    oqedge = ActiveRecord::Base.connection.execute("SELECT * FROM test_node_edge_oqgraph WHERE origid=#{@test_1.id} AND destid=#{@test_2.id};")
    assert_equal [nil,1,2,2.5,nil,nil], oqedge.first                                      
  end
  
  test "edge model deletion removes oqgraph edge" do
    @test_1.outgoing_nodes << @test_2
    edge = @test_1.outgoing_edges.find(:first, :conditions => {:to_id => @test_2.id})
    edge.destroy
    oqedge = ActiveRecord::Base.connection.execute("SELECT * FROM test_node_edge_oqgraph WHERE origid=#{@test_1.id} AND destid=#{@test_2.id};")
    assert_equal nil, oqedge.first
  end
  
  test "edge model update updates oqgraph edge" do
    edge = @test_1.create_edge_to(@test_2, 2.5) 
    edge.update_attributes(:weight => 3.0)
    oqedge = ActiveRecord::Base.connection.execute("SELECT * FROM test_node_edge_oqgraph WHERE origid=#{@test_1.id} AND destid=#{@test_2.id};") 
    assert_equal [nil,1,2,3,nil,nil], oqedge.first
    edge.update_attributes(:to_id => 3)
    oqedge = ActiveRecord::Base.connection.execute("SELECT * FROM test_node_edge_oqgraph WHERE origid=#{@test_1.id} AND destid=3;") 
    assert_equal [nil,1,3,3,nil,nil], oqedge.first
  end
  
  test "getting the shortest path" do
    #   a -- b -- c -- d
    @test_1.create_edge_to @test_2
    @test_2.create_edge_to @test_3
    @test_3.create_edge_to @test_4
    assert_equal [@test_1, @test_2, @test_3, @test_4], @test_1.shortest_path_to(@test_4)
    assert_equal ['a','b','c','d'], @test_1.shortest_path_to(@test_4).map(&:name)
  end
  
  test "complex getting the shortest path" do
    # 
    # a -- b -- c -- d
    #      |      / 
    #      e-- f 
    @test_1.create_edge_to @test_2
    @test_2.create_edge_to @test_3
    @test_3.create_edge_to @test_4
    @test_2.create_edge_to @test_5
    @test_5.create_edge_to @test_6
    @test_4.create_edge_to @test_6
    assert_equal [@test_1, @test_2, @test_5, @test_6], @test_1.shortest_path_to(@test_6)
  end
  
   test "shortest path returns the weight" do
     #   a -- b -- c -- d
     @test_1.create_edge_to @test_2, 2.0
     @test_2.create_edge_to @test_3, 1.5
     @test_3.create_edge_to @test_4, 1.2
     assert_equal [nil, 2.0 ,1.5, 1.2], @test_1.shortest_path_to(@test_4).map(&:weight)
   end
   
  test "getting the path weight total" do
    #   a -- b -- c -- d
     @test_1.create_edge_to @test_2, 2.0
     @test_2.create_edge_to @test_3, 1.5
     @test_3.create_edge_to @test_4, 1.2
     assert_equal 4.7, @test_1.path_weight_to(@test_4)
  end
  
  test "finding the path with breadth first" do
    @test_1.outgoing_nodes << @test_2
    @test_2.outgoing_nodes << @test_3
    @test_3.outgoing_nodes << @test_4
    assert_equal [@test_1, @test_2, @test_3, @test_4], @test_1.shortest_path_to(@test_4, :method => :breadth_first)
  end
  
  # 1 -> 2 -> 3
  test "getting originating nodes" do
    @test_1.create_edge_to @test_2
    @test_2.create_edge_to @test_3
    assert_equal [@test_2, @test_1] , @test_2.originating
  end
    
  test "getting the reachable nodes" do
    @test_1.create_edge_to @test_2
    @test_2.create_edge_to @test_3
    assert_equal [@test_2, @test_3] , @test_2.reachable
  end
  
  test "testing if the node is originating" do
    @test_1.create_edge_to @test_2
    @test_2.create_edge_to @test_3
    assert @test_2.originating?(@test_1)
    assert !@test_2.originating?(@test_3) 
  end
  
  test "get the incoming nodes" do
    @test_1.create_edge_to @test_2
    @test_2.create_edge_to @test_3
    assert_equal [@test_1], @test_2.incoming_nodes
  end
  
  test "get the outgoing nodes" do
    @test_1.create_edge_to @test_2
    @test_2.create_edge_to @test_3
    assert_equal [@test_3], @test_2.outgoing_nodes
  end
   
  test "duplicate links are ignored" do
    @test_1.create_edge_to @test_2
    assert_nothing_raised do
      @test_1.create_edge_to @test_2
    end
  end
   
  def test_duplicate_link_error
    ActiveRecord::Base.connection.execute("INSERT INTO test_node_edge_oqgraph (destid, origid, weight) VALUES (99,99,1.0);")   
    assert_raises ActiveRecord::StatementInvalid do
      ActiveRecord::Base.connection.execute("INSERT INTO test_node_edge_oqgraph (destid, origid, weight) VALUES (99,99,1.0);")
    end
  end

  def test_duplicate_link_error_fix
    ActiveRecord::Base.connection.execute("REPLACE INTO test_node_edge_oqgraph (destid, origid, weight) VALUES (99,99,1.0);")   
    assert_nothing_raised do
      ActiveRecord::Base.connection.execute("REPLACE INTO test_node_edge_oqgraph (destid, origid, weight) VALUES (99,99,1.0);")
    end
  end

  # There's an odd case here where MySQL would raise an error only when using Rails.
  def test_deletion_of_nonexistent_edge_raises_error
    edge = @test_1.create_edge_to @test_2
    ActiveRecord::Base.connection.execute("DELETE FROM test_node_edge_oqgraph WHERE destid = #{edge.to_id} AND origid = #{edge.from_id}")
    assert_nothing_raised do
      edge.destroy
    end
  end  
  
  def test_rebuild_graph
    @test_1.create_edge_to @test_2
    @test_2.create_edge_to @test_3
    @test_3.create_edge_to @test_4
    # Simulate the DB restart
    ActiveRecord::Base.connection.execute("DELETE FROM test_node_edge_oqgraph;")
    TestNode.rebuild_graph
   
    assert_equal [@test_1, @test_2, @test_3, @test_4], @test_1.shortest_path_to(@test_4)
    assert_equal ['a','b','c','d'], @test_1.shortest_path_to(@test_4).map(&:name)
  end
end