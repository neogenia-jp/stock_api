# model_test_helper.rb
# rails によって自動的に require されるファイル。
# ファイル名を変更しないで下さい。

require 'lib/test_case_common_plugins'
#require 'lib/timezone_plugin'

class ModelTestCase < ActiveSupport::TestCase
  include TestCaseCommonPlugins

  #include TimezonePlugin

  self.use_transactional_tests = false
end