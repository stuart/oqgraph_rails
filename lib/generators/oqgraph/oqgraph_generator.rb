require 'rails/generators/active_record'

module OQGraph
  module Generators
    class OQGraphGenerator < ActiveRecord::Generators::Base
      include Rails::Generators::ResourceHelpers
      
      namespace "oqgraph"
      source_root File.expand_path("../templates", __FILE__)
            
      desc "Generates a model with the given NAME with oqgraph and and edge model called <NAME>Edge" <<
      "plus a migration file for the edge model."

      def create_edge_model
         @node_class = file_name.camelize
         @edge_class = "#{@node_class}Edge"
         template "graph_edge.rb", File.join('app/models', "#{file_name}_edge.rb")
       end

       def create_node_model
         @node_class = file_name.camelize
         template "graph_node.rb", File.join('app/models', "#{file_name}.rb")
       end

       def create_edge_table_migration
         @edge_table_name = @edge_class.pluralize.underscore
         migration_template "graph_edge_migration.rb", "db/migrate/create_#{@edge_table_name}"
       end

       def create_oqgraph_migration
         @oqgraph_table_name = "#{file_name}_oqgraph"
         migration_template "graph_oqgraph_migration.rb", "db/migrate/create_#{@oqgraph_table_name}"
       end
    end
  end
end
