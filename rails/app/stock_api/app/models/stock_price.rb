class StockPrice < ApplicationRecord
  self.primary_key = [:code, :dt]

  scope :available, -> do
    where.not col_name_for_price => nil
  end

  scope :search_by_around_date, -> (code, target_date, days_of_range) do
    s = target_date - days_of_range.day
    e = target_date + days_of_range.day
    where(code: code).where('? <= dt', s).where('dt <= ?', e).order(:dt)
  end

  # 株価として参照するカラム名
  def self.col_name_for_price
    :close  # 終値を使う
  end

  # 株価
  def price
    send self.class.col_name_for_price
  end
end
