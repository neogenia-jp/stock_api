require 'open-uri'

class Scraping::StockPriceScraper < BaseService
  DEFAULT_DAYS_OF_RANGE = 14

  # 日付を指定して前後n日間の株価をスクレイピングする
  # @param code [String] 証券コード
  # @param target_date [Date] 検索対象日
  # @param days_of_range [Integer] 前後範囲日数
  # @return [Array<StockPrice>] 取得結果
  def scrape_around_by_date(code, target_date, days_of_range)
    s = target_date - days_of_range.day
    e = target_date + days_of_range.day
    url = "#{base_url}?code=#{code}&sy=#{s.year}&sm=#{s.month}&sd=#{s.day}&ey=#{e.year}&em=#{e.month}&ed=#{e.day}&tm=d"

    # Nokogiri::HTML::Documentを取得する
    html = logger.debug_scope "web accessing to '#{url}' ..." do
      Util::WebRequest.get(url)
    end
    logger.debug "web access finished successful."
    document = Nokogiri::HTML.parse(html.body)

    _extract_stock_prices(document).map do |ymd_str, close_str, normalized_str|
      StockPrice.new code: code, dt: _parse_date(ymd_str), close: _parse_decimal(close_str), normalized: _parse_decimal(normalized_str)
    end.to_a
  end

  private

  def base_url
    ENV.fetch 'STOCK_PRICE_BASE_URL'
  end

  # HTMLより株価情報を抽出する
  # @param document [Nokogiri::HTML::Document] HTMLドキュメント
  # @return [Enumerator<Array<String>>]  [日付, 終値, 調整後終値]の配列 例: [['2020年11月9日', '250', '125'], ...]
  def _extract_stock_prices(document)
    rows = document.xpath %q|//table[@class="boardFin yjSt marB6"]//tr|
    Enumerator.new do |y|
      rows.drop(1).reverse_each do |tr|
        ymd = tr.children.first.text
        y.yield [ymd, tr.children[-3].text, tr.children.last.text]
      end
    end
  end

  def _date_to_int(date)
    date.year * 10000 + date.month * 100 + date.day
  end

  def _parse_date(date_text)
    ymd = date_text.split(/[年月日]/).map(&:to_i)
    Date.new ymd[0], ymd[1], ymd[2]
  end

  def _parse_decimal(decimal_text)
    f = decimal_text.gsub(/,/,'').to_f
    f == 0.0 ? nil : f
  end
end
