class AddDaysToStockQuotations < ActiveRecord::Migration[6.0]
  def change
    remove_index :stock_quotations, column: [:code, :m]
    add_column :stock_quotations, :open_day,  :integer, null: false, default: 1, comment: '始値の日付', after: :open
    add_column :stock_quotations, :close_day, :integer,                          comment: '終値の日付', after: :close
    add_index :stock_quotations, [:code, :m, :open_day], unique: true
  end
end
