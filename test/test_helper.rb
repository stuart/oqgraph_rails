# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require 'rails'
require "rails/test_help"

# For generators
require 'rails/generators/test_case'
require 'active_record'