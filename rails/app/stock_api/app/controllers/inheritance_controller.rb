require 'nokogiri'

class InheritanceController < ApplicationController
  skip_forgery_protection  # CSRF検証を無効化

  def query
    words = params[:codes].split(',').map{|code| Util::StringNormalizer.normalize code}
    dt = params[:date].to_date
    dt0 = Date.new dt.year, dt.month, 1
    dt1 = dt0 - 1.month
    dt2 = dt0 - 2.month

    # 3ヶ月分の月間相場情報を検索
    # TODO: 日付を複数指定して呼び出しを１回だけにできないか？
    q0 = StockQuotation.get_grouped(words, dt0)
    q1 = StockQuotation.get_grouped(words, dt1)
    q2 = StockQuotation.get_grouped(words, dt2)

    # 証券コードだけを集める
    codes = [q0, q1, q2].map(&:values).flatten.select{|sp| sp.is_a? StockQuotation }.map(&:code).uniq

    # 当日終値を検索
    ps = _get_closing_prices codes, dt

    render xml: _create_xml(words, ps, q0, q1, q2)
  end

  private

  # 終値を取得する
  # @param codes [Array<String>] 証券コードの配列
  # @param dt [Date] 検索対象日付
  # @return [Hash<String, BigDecimal>] {証券コード => 株価} なハッシュ
  def _get_closing_prices(codes, dt)
    f = Stocks::StockPriceFinder.new
    ret = {}
    codes.each do |code|
      ret[code] = f.get_stock_price_by_date(code, dt)
    end
    ret
  end

  def _create_xml(words, ps, q0, q1, q2)
    err_msg = I18n.t 'errors.stocks.stock_splitted'
    err_msg2 = I18n.t 'errors.stocks.too_many_hits'

    Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.results do
        words.each do |word|
          q = q0[word] || q1[word] || q2[word]  # 代表データ

          # 検索失敗判定
          msg = if q.nil?
                  I18n.t 'errors.stocks.not_found', word: word
                elsif q == :too_many_hits
                  err_msg2
                end

          xml.record do
            if msg
              xml.code ''
              xml.name word
              xml.closing_price ''
              xml.for_month ''
              xml.for_previous_month ''
              xml.for_previous_two_months ''
              xml.error msg
            else
              for_month = q0.single(word, :avg_closing, err_msg) # 当月の月間平均
              closing_price = for_month==err_msg ? err_msg : ps[q.first.code] # 月間平均がエラーならその日の終値もエラーにする
              xml.code q.first.code
              xml.name q.first.name
              xml.closing_price closing_price
              xml.for_month for_month
              xml.for_previous_month q1.single(word, :avg_closing, err_msg)
              xml.for_previous_two_months q2.single(word, :avg_closing, err_msg)
            end
          end
        end
      end
    end
  end
end
