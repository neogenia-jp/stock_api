module CommonCustomMatcher
  def assert_array_match(expected_regexp, array, error_message = nil)
    assert array.find { |e| expected_regexp =~ e}, error_message || "#{array}の中に、#{expected_regexp.inspect}にマッチするデータが存在しません。"
  end
end
