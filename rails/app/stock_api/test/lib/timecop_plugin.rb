require 'timecop'

# このモジュールは teardown メソッドを上書きするので要注意！
module TimecopPlugin
  def teardown
    super
    Timecop.return
  end
end
