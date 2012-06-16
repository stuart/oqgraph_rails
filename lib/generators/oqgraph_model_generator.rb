module OQGraph
  module Generators
    class OQGraphModelGenerator < Rails::Generators::NamedBase
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
    end
  end
end