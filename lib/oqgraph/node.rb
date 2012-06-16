module OQGraph
  module Node
    def self.included base
      base.instance_eval do
        def self.edge_class_name
          "#{self.name}Edge"
        end
        
        def self.edge_class
          edge_class_name.constantize
        end
        
        def self.rebuild_graph
          edge_class.create_graph_table
        end
        
        has_many :outgoing_edges, {
           :class_name => edge_class_name,
           :foreign_key => :from_id,
           :include => :to,
           :dependent => :destroy
         }
  
        has_many :incoming_edges, {
           :class_name => edge_class_name,
           :foreign_key => :to_id,
           :include => :from,
           :dependent => :destroy
         }
  
        has_many :outgoing_nodes, :through => :outgoing_edges, :source => :to
        has_many :incoming_nodes, :through => :incoming_edges, :source => :from
      end
    end
    
    # Creates a one way edge from this node to another with a weight.
    def create_edge_to(other, weight = 1.0)
      edge_class.create!(:from_id => id, :to_id => other.id, :weight => weight)
    end
    
    # +other+ graph node to edge to
    # +weight+ positive float denoting edge weight
    # Creates a two way edge between this node and another.
    def create_edge_to_and_from(other, weight = 1.0)
      edge_class.create!(:from_id => id, :to_id => other.id, :weight => weight)
      edge_class.create!(:from_id => other.id, :to_id => id, :weight => weight)
    end
    
    # +other+ The target node to find a route to
    # +options+ A hash of options: Currently the only option is
    #            :method => :djiskstra or :breadth_first
    # Returns an array of nodes in order starting with this node and ending in the target
    # This will be the shortest path from this node to the other.
    # The :djikstra method takes edge weights into account, the :breadth_first does not.
    def shortest_path_to(other, options = {:method => :djikstra})
      edge_class.shortest_path(self,other, options)
    end
    
    # +other+ The target node to find a route to 
    # Gives the path weight as a float of the shortest path to the other
    def path_weight_to(other)
      edge_class.shortest_path(self,other,:method => :djikstra).map{|edge| edge.weight.to_f}.sum
    end
    
    # Returns an array of all nodes which can trace to this node
    def originating
      edge_class.originating_nodes(self)
    end
    
    # true if the other node can reach this node.
    def originating?(other)
      originating.include?(other)
    end
    
    # Returns all nodes reachable from this node.
    def reachable
      edge_class.reachable_nodes(self)
    end
    
    def edge_class
      self.class.edge_class_name.constantize
    end
  end
end