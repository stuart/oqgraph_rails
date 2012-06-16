class Create<%= table_name.camelize %>Migration < ActiveRecord::Migration
  # This migration creates the persistent database for the oqgraph table store.
  # The edge class will create it's own OQGraph table called: <%= table_name %>_oqgraph
  
  def change
    create_table(:<%= table_name %>) do |t|
      t.integer :from_id, :null => false
      t.integer :to_id,   :null => false
      t.double  :weight, :default => 1.0
    end
  end
end