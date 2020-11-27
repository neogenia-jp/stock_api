require 'csv'

class Importers::QuotationImporter
  CHUNK_SIZE = 300 # 1 にすると1件ずつインサートされるのでデバッグ時に有効

  # CSVファイルをインポートする
  # 期待するヘッダ: 年月 銘柄コード 銘柄名称 始値 日付 高値 日付 安値 日付 終値 日付 終値平均
  def import_csv(file_path)
    csv_data = CSV.read(file_path, headers: true)
    cnt = 0

    logger.debug "#{self.class} --- import started ---"
    ActiveRecord::Base.transaction do
      # 小分けにしてバルクインサート
      generate_models(csv_data).each_slice(CHUNK_SIZE).each do |chunk|
        begin
          if cnt == 0
            # はじめに既存データを削除
            StockQuotation.where(m: chunk.first.m).delete_all
          end
          StockQuotation.import chunk
          cnt += chunk.count
          logger.debug "#{self.class}  - #{cnt} records imported."
        rescue => ex
          logger.error ex
          logger.error "data: #{chunk}"
          raise
        end
      end
    end
    logger.debug "#{self.class} --- import finished ---"

    cnt
  end

  private

  # CSVデータからモデルを生成する
  # @param csv_data [CSV::Table]
  # @return [Enumerator<StockQuotation>]
  def generate_models(csv_data)
    idx_open_day = csv_data.headers.find_index('始値') + 1
    idx_close_day = csv_data.headers.find_index('終値') + 1

    Enumerator.new do |y|
      csv_data.each do |data|
        name = data['銘柄名称']&.gsub(/　普通株式/, '')
        model = StockQuotation.new(
            m: "#{data['年月']}/01".to_date,
            code: data['銘柄コード'],
            name: name,
            normalized_name: Util::StringNormalizer.normalize(name),
            open: data['始値'],
            open_day: data[idx_open_day],
            high: data['高値'],
            low: data['安値'],
            close: data['終値'],
            close_day: data[idx_close_day],
            avg_closing: data['終値平均']
          )
        next if model.avg_closing.blank?  # 終値平均がないデータは無視
        y.yield model
      end
    end
  end
end
