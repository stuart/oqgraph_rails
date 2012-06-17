module OQGraph
  module EdgeClassMethods
    
    ##
    # Creates the OQGraph table for the edge model.
    # This table exists in memory only and needs to
    # be updated on every database restart.
    def create_graph_table
      connection.execute <<-EOS
      CREATE TABLE IF NOT EXISTS #{oqgraph_table_name} (
          latch   SMALLINT  UNSIGNED NULL,
          origid  BIGINT    UNSIGNED NULL,
          destid  BIGINT    UNSIGNED NULL,
          weight  DOUBLE    NULL,
          seq     BIGINT    UNSIGNED NULL,
          linkid  BIGINT    UNSIGNED NULL,
          KEY (latch, origid, destid) USING HASH,
          KEY (latch, destid, origid) USING HASH
        ) ENGINE=OQGRAPH;
      EOS
  
      # if the DB server has restarted then there will be no records in the oqgraph table.
      update_graph_table
    end
    
    def update_graph_table
      update_oqgraph unless up_to_date?
    end
    
    # Returns the shortest path from node to node.
    # +options+ A hash containing options.
    # The only option is :method which can be 
    # :breadth_first to do a breadth first search.
    # It defaults to using Djikstra's algorithm.
    def shortest_path(from, to, options)
      latch = case options[:method]
        when :breadth_first then 2
        else 1
      end  
      latch = 1
      latch = 2 if options[:method] == :breadth_first

      sql = <<-EOS
       WHERE latch = #{latch} AND origid = #{from.id} AND destid = #{to.id}
       ORDER BY seq;
      EOS

      node_class.find_by_sql select_for_node << sql
    end
    
    # Finds all the nodes that lead to the node
    def originating_nodes(node)    
      sql = <<-EOS
       WHERE latch = 2 AND destid = #{node.id}
       ORDER BY seq;
      EOS

      node_class.find_by_sql select_for_node << sql 
    end

    # Finds all the nodes that are reachable from the node
    def reachable_nodes(node)    
      sql = <<-EOS
       WHERE latch = 1 AND origid = #{node.id}
       ORDER BY seq;
      EOS

      node_class.find_by_sql select_for_node << sql 
    end
    
    # Finds the edges leading directly into the node
    def in_edges(node)
      sql = <<-EOS
       WHERE latch = 0 AND destid = #{node.id}
      EOS

      node_class.find_by_sql select_for_node << sql 
    end

    # Finds the edges leading directly out of the node
    def out_edges(node)    
      sql = <<-EOS
       WHERE latch = 0 AND origid = #{node.id}
      EOS

      node_class.find_by_sql select_for_node << sql 
    end
    
    def node_table
      node_class.table_name
    end
    
  private
    def select_for_node
      sql = "SELECT "
      sql << node_class.columns.map{|column| "#{node_table}.#{column.name}"}.join(",")
      sql << ", #{oqgraph_table_name}.weight FROM #{oqgraph_table_name} JOIN #{node_table} ON (linkid=id) "
    end
    
    def oqgraph_table_name
      "#{node_table.singularize}_oqgraph"
    end
    
    def up_to_date?
      # Really need a better way to do this.
      self.count == connection.select_value("SELECT COUNT(*) FROM #{oqgraph_table_name}") 
    end
  
    def update_oqgraph
      connection.execute <<-EOS
        REPLACE INTO #{oqgraph_table_name} (origid, destid, weight)
        SELECT from_id, to_id, weight FROM #{table_name} 
        WHERE from_id IS NOT NULL AND to_id IS NOT NULL
      EOS
    end
  end
end