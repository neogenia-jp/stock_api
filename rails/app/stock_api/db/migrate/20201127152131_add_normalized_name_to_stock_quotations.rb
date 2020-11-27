class AddNormalizedNameToStockQuotations < ActiveRecord::Migration[6.0]
  def change
    add_column :stock_quotations, :normalized_name, :string, null: false, default: '', comment: '検索用に正規化された名称', after: :name
  end
end
