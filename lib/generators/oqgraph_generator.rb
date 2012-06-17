require 'generators/active_record/oqgraph_generator'

module OQGraph
  module Generators
    class OQGraphGenerator < Rails::Generators::NamedBase
      include Rails::Generators::ResourceHelpers
      
      namespace "oqgraph"
      source_root File.expand_path("../templates", __FILE__)
            
      desc "Generates a model with the given NAME with oqgraph and and edge model called <NAME>Edge" <<
      "plus a migration file for the edge model."
      
      hook_for :orm
      
    end
  end
end
