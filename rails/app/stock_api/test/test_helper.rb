ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
#require 'minitest/reporters'
#require 'minitest/retry'
require 'factory_girl'
require 'lib/common_custom_matcher'
require 'lib/test_with_options_plugin'
require 'lib/cleanup_plugin'
require 'lib/timecop_plugin'
#require 'lib/tmp_model_plugin'
require 'lib/create_data_helper_plugin'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  #parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #fixtures :all

  # Add more helper methods to be used by all tests here...
  include CommonCustomMatcher
end

FactoryGirl.find_definitions

require 'lib/model_test_helper'
#require 'lib/integration_test_helper'
#require 'lib/controller_test_helper'
require 'lib/mail_test_helper'
