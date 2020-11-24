class CreateStockQuotations < ActiveRecord::Migration[6.0]
  def change
    create_table :stock_quotations, id: false, comment: '月間相場情報' do |t|
      t.string  :code,        null: false, comment: '証券コード'
      t.date    :m,           null: false, comment: '年月'
      t.string  :name,        null: false, comment: '名称'
      t.decimal :open,        null: true,  comment: '始値'
      t.decimal :high,        null: true,  comment: '高値'
      t.decimal :low,         null: true,  comment: '安値'
      t.decimal :close,       null: true,  comment: '終値'
      t.decimal :avg_closing, null: true,  comment: '平均終値'

      t.timestamps

      t.index [ :code, :m ], unique: true
    end
  end
end
