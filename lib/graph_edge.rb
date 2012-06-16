require 'edge_instance_methods'
require 'edge_class_methods'

module OQGraph
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