class Stocks::StockPriceFinder < BaseService
  DEFAULT_DAYS_OF_RANGE = 14

  # 株価を取得します
  # @param code [String] 証券コード
  # @param date [Date] 検索対象日
  # @return [StockPrice|nil] 株価
  def get_stock_price_by_date(code, date)
    # DB検索
    stock_prices = StockPrice.available.search_by_around_date(code, date, DEFAULT_DAYS_OF_RANGE)
    # 日付で探索
    result = _search stock_prices, date, required_lt_and_gt_both: true
    return result if result.present?

    # スクレイピング
    stock_prices = Scraping::StockPriceScraper.new.scrape_around_by_date(code, date, DEFAULT_DAYS_OF_RANGE)
    # 結果をDBに保存しておく
    StockPrice.where(code: code).where(dt: stock_prices.map(&:dt)).delete_all
    StockPrice.import stock_prices

    # 日付で探索
    _search stock_prices, date
  end

  private

  # 日付を指定して採用する株価を検索する
  # @param stock_prices [Array<StockPrice>] 検索対象データ（日付の昇順にソート済みであること）
  # @param target_date [Date] 検索対象日
  # @param required_lt_and_gt_both [Boolean] 対象日の前後の株価を探索する際に、前後両方揃っていない場合は例外とするかどうか
  # @return [BigDecimal] 株価
  def _search(stock_prices, target_date, required_lt_and_gt_both: false)
    lt = nil  # 指定日より過去で、最も近い日の株価をセットします
    gt = nil  # 指定日より未来で、最も近い日の株価をセットします

    stock_prices.each do |sp|
      case sp.dt <=> target_date
      when 0  # 対象日と一致
        return sp.price
      when 1  # 対象日より過去
        gt = sp
        break  # ループ中止
      else # 対象より未来
        lt = sp
      end
    end

    if lt.nil? || gt.nil?
      return nil if required_lt_and_gt_both
      return lt.price if lt!=nil
      return gt.price if gt!=nil
      return nil  # 両方 nil の場合
    end

    # 日付のより近い方を採用する
    lt_distance = target_date - lt.dt
    gt_distance = gt.dt - target_date
    case lt_distance <=> gt_distance
    when 0  # lt と gt の日付差が同じ
      (lt.price + gt.price) / 2
    when 1  # lt の方が日付差が大きい
      gt.price
    else  # gt の方が日付差が小さい
      lt.price
    end
  end

end
