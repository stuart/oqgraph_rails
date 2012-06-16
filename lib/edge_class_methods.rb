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
      if !up_to_date?
        update_oqgraph
      end
    end

    def reload_table
      
    end
  private
    def oqgraph_table_name
      "#{self.name.underscore}_oqgraph"
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