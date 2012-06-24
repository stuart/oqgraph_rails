require 'test_helper'
require 'generators/oqgraph/oqgraph_generator'
class OQgraphGeneratorTest < Rails::Generators::TestCase
  tests OQGraph::Generators::OQGraphGenerator
  
  destination File.expand_path("../tmp", __FILE__)
  setup :prepare_destination
  
  test "creates the correct migration file" do
    run_generator %w(funky)
    assert_migration 'db/migrate/create_funky_edges', /create_table :funky_edges do/
  end
  
  test "creates the edge model class" do
    run_generator %w(funky)
    assert_file 'app/models/funky_edge.rb', /class FunkyEdge < ActiveRecord::Base/
  end
  
  test "created edge model class is parseable ruby" do
    run_generator %w(funky)
    assert_nothing_raised do
      require 'tmp/app/models/funky_edge'
    end
  end
  
  test "creates the node model class" do
    run_generator %w(funky)
    assert_file 'app/models/funky.rb', /class Funky < ActiveRecord::Base/
  end
  
  test "created node model class is parseable ruby" do
    run_generator %w(funky)
    assert_nothing_raised do
      require 'tmp/app/models/funky'
    end
  end
  
  test "creates the oqgraph table migration" do
    run_generator %w(funky)
    assert_migration 'db/migrate/create_funky_oqgraph.rb'
  end
  
end