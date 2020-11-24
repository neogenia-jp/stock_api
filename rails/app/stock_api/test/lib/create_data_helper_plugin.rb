module CreateDataHelperPlugin
  # [[:colum1 :column2, :column3],
  #  [data1-1, data1-2, data1-3],
  #  [data2-1, data2-2, data2-3],
  #  ...
  # ]
  # の形式で配列を渡すと１行目をカラム名、
  # ２行目以降の各行をテーブルの１行として引数で渡されたモデルクラスのsave!で保存する
  # ブロックが渡された場合、１行目をキー、各行を値としてHashが渡されるので、
  # そこで共通の加工が必要であればHashの内容を更新するとその内容でsave!される。
  def _create_data_helper(data, model)
    columns = data.shift
    data.each do |d|
      h = columns.zip(d).to_h
      yield h if block_given?
      model.new(h).save!
    end
  end

  # create_data_helper の拡張版
  def create_data(model, data=nil)
    _create_data_helper data, model if data.present?
    _create_data_helper yield, model if block_given?
  end
end
