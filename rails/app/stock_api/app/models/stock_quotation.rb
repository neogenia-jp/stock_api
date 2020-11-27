class StockQuotation < ApplicationRecord
  self.primary_key = [:code, :m, :open_day]

  scope :code_and_month, -> (code, month) do
    where(code: code).where(m: month)
  end

  class << self
    def get_grouped(code, month)
      h = StockQuotation.code_and_month(code, month).to_a.group_by(&:code)
      h.define_singleton_method(:single) do |key, method=nil, error_msg=nil|
        a = h[key]
        if a.nil?
          nil
        elsif a.count >= 2
          if method
            error_msg
          else
            raise error_msg || "expected singleton element, but actual duplicated. key=#{key} count=#{a.count}"
          end
        else
          if method
            a.first.send method
          else
            a.first
          end
        end
      end
      h
    end
  end
end
