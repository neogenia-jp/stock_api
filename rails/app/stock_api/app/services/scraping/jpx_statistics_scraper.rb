require 'open-uri'

class Scraping::JpxStatisticsScraper < BaseService
  BASE_URL = 'https://www.jpx.co.jp'

  # JPX 月間相場情表へのリンクを取得します
  #
  # @param yyyymm [String] 取得対象年月
  # @return [Array<String>] 取得されたリンク
  def get_st_links(yyyymm)
    raise "Invalid date format. expected format is 'yyyymm', but actual: '#{yyyymm}'" unless yyyymm.match /^\d{6}$/
    yyyy = "#{yyyymm}01".to_date.year
    current_y = Time.now.year
    url = "#{BASE_URL}/markets/statistics-equities/price/"
    url += current_y == yyyy ? "index.html" : "00-archives-%02d.html"%[current_y - yyyy]

    # Nokogiri::HTML::Documentを取得する
    html = Util::WebRequest.get(url)
    document = Nokogiri::HTML.parse(html.body)

    _get_links(document).select{|l| l.match %r|/st\d*_#{yyyymm}.*\.pdf$| }.map{|l| BASE_URL + l}
  end

  private

  # テーブル要素から、リンク要素を抽出する
  # @param document [Nokogiri::HTML::Document] HTMLドキュメント
  # @return [Array<String>] 取得されたリンクURL
  def _get_links(document)
    links = document.xpath %q|//*[@id="readArea"]//div[@class="component-normal-table"]//a|
    links.map { |l| l.attributes['href'].value }
  end

end
