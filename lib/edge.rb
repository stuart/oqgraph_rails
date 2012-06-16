require 'edge_instance_methods'

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

        include OQGraph::EdgeInstanceMethods
        extend OQGraph::EdgeClassMethods
      end
    end
  end
  
  # Check that we have the OQGraph engine plugin installed in MySQL
  def check_for_oqgraph_engine
    begin
      result = false
      engines = ActiveRecord::Base.connection.execute("SHOW ENGINES")
      engines.each do |engine|
        result = true if (engine[0]=="OQGRAPH" and engine[1]=="YES")
      end
      return result
    rescue ActiveRecord::StatementInvalid => e
      raise "MySQL or MariaDB 5.1 or above with the OQGRAPH engine is required for the acts_as_oqgraph gem.\nThe following error was raised: #{e.inspect}"
    end
  end
end