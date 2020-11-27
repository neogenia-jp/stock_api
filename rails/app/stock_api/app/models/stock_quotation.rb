class StockQuotation < ApplicationRecord
  self.primary_key = [:code, :m, :open_day]

  scope :code_and_month, -> (code, month) do
    where(code: code).where(m: month)
  end

  scope :normalized_name_and_month, -> (name, month) do
    where('normalized_name like ?', "%#{name}%").where(m: month)
  end

  class << self
    # 検索を実行し、検索条件ごとに結果をまとめてハッシュ化して返す
    # 検索結果が複数件だった場合は :too_many_hits が検索結果にセットされる
    # @param words [Array<String>] 検索ワードの配列
    # @param month [Date] 検索対象月（日付部分は1日とすること）
    # @return [Hash<String, StockPrice>]  { 検索ワード => 検索結果 } なハッシュ
    def get_grouped(words, month)
      h = {}        # 戻り値
      codes = {}    # 証券コード検索用の検索キー保持用
      [words].flatten.map{ |word| [word, Util::StringNormalizer.normalize(word)] }.uniq.each do |word, normalized|
        if normalized.match /\d{4}/
          # 数字４桁であれば証券コードとみなし、あとでまとめて検索
          codes[normalized] = word
        else
          # 名称で部分一致検索
          result = StockQuotation.normalized_name_and_month(normalized, month)
          case result.count <=> 1
          when 0  # 1件だけヒットしたとき
            h[word] = result
          when 1  # 複数件ヒットしたとき
            h[word] = :too_many_hits
          end
        end
      end

      if codes.present?
        # 証券コードで検索
        StockQuotation.code_and_month(codes.keys, month).each do |sq|
          word = codes[sq.code]
          (h[word] ||= []) << sq
        end
      end

      # 戻り値に single() というメソッドを生やす
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
