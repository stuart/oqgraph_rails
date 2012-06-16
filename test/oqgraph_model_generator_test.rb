require 'test_helper'
require 'generators/oqgraph_model_generator'
class OQgraphModelGeneratorTest < Rails::Generators::TestCase
  tests OQGraph::Generators::OQGraphModelGenerator
  
  destination File.expand_path("../tmp", __FILE__)
  setup :prepare_destination
  
  test "creates the edge model class" do
    run_generator %w(funky)
    assert_file 'app/models/funky_edge.rb', /class FunkyEdge < ActiveRecord::Base/
  end
end