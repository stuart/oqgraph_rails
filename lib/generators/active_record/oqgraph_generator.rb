require 'rails/generators/active_record'

module ActiveRecord
  module Generators
    class OQGraphGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path("../templates", __FILE__)
      
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
      
      def create_initializer
        template "graph_initializer.rb", File.join("config/initializers/#{file_name}_oqgraph.rb")
      end
    end
  end
end