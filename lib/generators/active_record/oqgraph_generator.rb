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
        migration_template "graph_edge_migration.rb", "db/migrate/#{table_name}"
      end
      
    end
  end
end