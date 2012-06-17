class Create<%= @edge_class.pluralize %> < ActiveRecord::Migration
  # This migration creates the persistent database for the oqgraph table store.
  # The edge class will create it's own OQGraph table called: <%= @edge_table_name %>_oqgraph
  
  def change
    create_table :<%= @edge_table_name %> do |t|
      t.integer :from_id, :null => false
      t.integer :to_id,   :null => false
      t.float   :weight, :default => 1.0
    end
  end
end