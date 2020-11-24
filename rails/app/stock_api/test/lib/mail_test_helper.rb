# mail_test_helper.rb
# rails によって自動的に require されるファイル。
# ファイル名を変更しないで下さい。

require 'lib/test_case_common_plugins'

class MailTestCase < ActionMailer::TestCase
  include TestCaseCommonPlugins
end