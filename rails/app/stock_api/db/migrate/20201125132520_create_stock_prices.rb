class CreateStockPrices < ActiveRecord::Migration[6.0]
  def change
    create_table :stock_prices, id: false, comment: '株価' do |t|
      t.string  :code,        null: false, comment: '証券コード'
      t.date    :dt,          null: false, comment: '日付'
      t.decimal :close,       null: true,  comment: '終値'
      t.decimal :normalized,  null: true,  comment: '調整後終値'

      t.timestamps

      t.index [ :code, :dt ], unique: true
    end
  end
end
