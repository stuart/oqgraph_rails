module OQGraph
  module EdgeInstanceMethods
  private
    def add_to_graph
      connection.execute <<-EOS
        REPLACE INTO #{oqgraph_table_name} (origid, destid, weight)
        SELECT #{from_id || 0}, #{to_id || 0}, #{weight || 1.0}
      EOS
    end
  
    def remove_from_graph
      if self.class.where(:from_id => from_id, :to_id => to_id).count == 0
        connection.execute <<-EOS
          DELETE IGNORE FROM #{oqgraph_table_name} 
          WHERE origid = #{from_id}
          AND destid = #{to_id};
        EOS
      end
    end
  
    def update_graph
      connection.execute <<-EOS
        UPDATE #{oqgraph_table_name} 
        SET origid = #{from_id}, 
            destid = #{to_id}, 
            weight = #{weight} 
        WHERE origid = #{from_id_was} AND destid = #{to_id_was};
      EOS
    end
    
    def oqgraph_table_name
      "#{self.class.name.underscore}_oqgraph"
    end
  end
end