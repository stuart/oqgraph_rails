class Create<%= @edge_class %>OQgraph < ActiveRecord::Migration
  
  def up
    ActiveRecord::Base.connection.execute <<-EOS
      CREATE TABLE IF NOT EXISTS <%= @oqgraph_table_name %> (
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
  end
  
  def down
    drop_table '<%= @oqgraph_table_name %>'
  end
end