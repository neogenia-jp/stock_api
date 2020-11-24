class StockQuotation < ApplicationRecord
  self.primary_key = [:code, :m]

end
