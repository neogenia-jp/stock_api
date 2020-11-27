require 'nokogiri'

class InheritanceController < ApplicationController
  skip_forgery_protection  # CSRF検証を無効化

  def query
    codes = params[:codes].split(',')
    dt = params[:date].to_date
    dt0 = Date.new dt.year, dt.month, 1
    dt1 = dt0 - 1.month
    dt2 = dt0 - 2.month

    q0 = StockQuotation.get_grouped(codes, dt0)
    q1 = StockQuotation.get_grouped(codes, dt1)
    q2 = StockQuotation.get_grouped(codes, dt2)
    ps = _get_closing_prices codes, dt

    render xml: _create_xml(codes, ps, q0, q1, q2)
  end

  private

  # 終値を取得する
  # @param codes [Array<String>] 証券コードの配列
  # @return [Hash<String, BigDecimal>] {証券コード => 株価} なハッシュ
  def _get_closing_prices(codes, dt)
    f = Stocks::StockPriceFinder.new
    ret = {}
    codes.uniq.each do |code|
      ret[code] = f.get_stock_price_by_date(code, dt)
    end
    ret
  end

  def _create_xml(codes, ps, q0, q1, q2)
    err_msg = I18n.t 'errors.stocks.stock_splitted'

    Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.results do
        codes.each do |code|
          q = (q0[code] || q1[code] || q2[code])&.first  # 代表データを検索
          xml.record do
            xml.code code
            xml.name q&.name
            xml.closing_price ps[code]
            xml.for_month q0.single(code, :avg_closing, err_msg)
            xml.for_previous_month q1.single(code, :avg_closing, err_msg)
            xml.for_previous_two_months q2.single(code, :avg_closing, err_msg)
            xml.error "code '#{code}' not found." unless q
          end
        end
      end
    end
  end
end
