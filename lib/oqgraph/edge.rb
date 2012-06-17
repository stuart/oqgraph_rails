require 'oqgraph/edge_instance_methods'
require 'oqgraph/edge_class_methods'

module OQGraph
  module Edge
    def self.included base
      base.instance_eval do  
        def self.node_class_name
          self.name.gsub(/Edge$/,'')
        end
        
        def self.node_class
          node_class_name.constantize 
        end
        
        self.table_name = name.underscore.pluralize
        
        after_create  :add_to_graph
        after_destroy :remove_from_graph
        after_update  :update_graph

        belongs_to :from, :class_name => node_class_name, :foreign_key => :from_id
        belongs_to :to,   :class_name => node_class_name, :foreign_key => :to_id
        
        attr_accessible :from_id, :to_id, :weight
        
        include OQGraph::EdgeInstanceMethods
        extend OQGraph::EdgeClassMethods
      end
    end
  end
end


