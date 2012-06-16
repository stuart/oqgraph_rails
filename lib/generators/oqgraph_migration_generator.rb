require 'rails/generators/active_record'

module ActiveRecord
  module Generators
    class OQGraphMigrationGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path("../templates", __FILE__)
      
      def create_edge_table_migration
        migration_template "graph_edge_migration.rb", "db/migrate/#{table_name}"
      end
    end
  end
end