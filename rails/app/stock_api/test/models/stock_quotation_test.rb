require 'test_helper'

class StockQuotationTest < ActiveSupport::TestCase
  test "avg_closing が未入力ならバリデーションエラーになること" do
    instance = StockQuotation.new
    
    assert_not instance.valid?

    instance.avg_closing = 1
    assert instance.valid?
  end
  test "open_day が32以上はバリデーションエラーになること" do
    instance = StockQuotation.new
    instance.avg_closing = 1
    
    instance.open_day = 32
    assert_not instance.valid?

    instance.open_day = 31
    assert instance.valid?
  end
end
