require 'nokogiri'

class InheritanceController < ApplicationController
  skip_forgery_protection  # CSRF検証を無効化

  def query
    codes = params[:codes].split(',')
    dt = params[:date].to_date
    dt0 = Date.new dt.year, dt.month, 1
    dt1 = dt0 - 1.month
    dt2 = dt0 - 2.month

    ps = _get_closing_prices codes, dt
    q0 = StockQuotation.where(code: codes).where(m: dt0).to_a.group_by(&:code)
    q1 = StockQuotation.where(code: codes).where(m: dt1).to_a.group_by(&:code)
    q2 = StockQuotation.where(code: codes).where(m: dt2).to_a.group_by(&:code)

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
    Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.results do
        codes.each do |code|
          q = (q0[code] || q1[code] || q2[code])&.first  # 代表データを検索
          xml.record do
            xml.code code
            xml.name q&.name
            xml.closing_price ps[code]
            xml.for_month q0[code]&.first&.avg_closing
            xml.for_previous_month q1[code]&.first&.avg_closing
            xml.for_previous_two_months q2[code]&.first&.avg_closing
            xml.error "code '#{code}' not found." unless q
          end
        end
      end
    end
  end
end
