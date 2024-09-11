require 'test_helper'

class StockQuotationTest < ActiveSupport::TestCase
  test "open_day が32以上はバリデーションエラーになること" do
    instance = StockQuotation.new
    
    instance.open_day = 32
    assert_not instance.valid?

    instance.open_day = 31
    assert instance.valid?
  end
end
