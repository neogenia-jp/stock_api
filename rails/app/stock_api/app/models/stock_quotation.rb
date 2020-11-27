class StockQuotation < ApplicationRecord
  self.primary_key = [:code, :m, :open_day]

end
