require 'nokogiri'

class InheritanceController < ApplicationController
  skip_forgery_protection  # CSRF検証を無効化

  def query
    codes = params[:codes].split(',')
    dt = params[:date].to_date
    dt0 = Date.new dt.year, dt.month, 1
    dt1 = dt0 - 1.month
    dt2 = dt0 - 2.month

    q0 = StockQuotation.where(code: codes).where(m: dt0).to_a.group_by(&:code)
    q1 = StockQuotation.where(code: codes).where(m: dt1).to_a.group_by(&:code)
    q2 = StockQuotation.where(code: codes).where(m: dt2).to_a.group_by(&:code)

    render xml: create_xml(codes, q0, q1, q2)
  end

  def create_xml(codes, q0, q1, q2)
    Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.results do
        codes.each do |code|
          q = (q0[code] || q1[code] || q2[code])&.first  # 代表データを検索
          xml.record do
            xml.code code
            if q
              xml.name q.name
              xml.closing_price q0[code]&.first&.close
              xml.for_month q0[code]&.first&.avg_closing
              xml.for_previous_month q1[code]&.first&.avg_closing
              xml.for_previous_two_months q2[code]&.first&.avg_closing
            else
              xml.error "code '#{code}' not found."
            end
          end
        end
      end
    end
  end
end
