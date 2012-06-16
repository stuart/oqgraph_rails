class Create<%= table_name.camelize %>Migration < ActiveRecord::Migration
  # This migration creates the persistent database for the oqgraph table store.
  def change
    create_table(:<%= table_name %>) do |t|
      t.integer :from_id, :null => false
      t.integer :to_id,   :null => false
      t.double  :weight
    end
  end
end