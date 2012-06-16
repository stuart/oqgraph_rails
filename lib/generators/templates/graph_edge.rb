class <%= @node_class %>Edge < ActiveRecord::Base
  extend ::OQGraph::EdgeClassMethods
  includes ::OQGraph::EdgeInstanceMethods
  
  after_create  :add_to_graph
  after_destroy :remove_from_graph
  after_update  :update_graph
  
  belongs_to :from, :class_name => '<%= @node_class %>'
  belongs_to :to, :class_name => '<%= @node_class %>'
  
  validates :from_id, :presence => true
  validates :to_id,   :presence => true
  
  self.table_name = '<%= @edge_class.underscore.pluralize %>'
  
end