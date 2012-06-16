require 'test_helper'
require 'generators/oqgraph_migration_generator'
class OQgraphMigrationGeneratorTest < Rails::Generators::TestCase
  tests ActiveRecord::Generators::OQGraphMigrationGenerator
  
  destination File.expand_path("../tmp", __FILE__)
  setup :prepare_destination
  
  test "creates the correct migration file" do
    run_generator %w(funky)
    files = Dir.glob('test/tmp/db/migrate/*')
    assert_match /[0-9]+_funkies/, files[0]
  end
  
end