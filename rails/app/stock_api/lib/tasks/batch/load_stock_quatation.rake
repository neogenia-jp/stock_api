require 'tasks/batch/batch_helper'

namespace :batch do
  namespace :quotations do
    desc '月間相場情報をロードします[yyyymm]'
    batch_task :load, %i/yyyymm/ do |task, args|
      yyyymm = args['yyyymm']
      if yyyymm.blank?
        yyyymm = (Date.today - 1.month).strftime('%Y%m')
        logger.info "try download latest '#{yyyymm}' year/month"
      else
        # argument check.
        raise "Invalid date format. expected format is 'yyyymm', but actual: '#{yyyymm}'" unless yyyymm.match /^\d{6}$/
      end

      sc = Scraping::JpxStatisticsScraper.new
      sc.get_st_links(yyyymm).each do |url|
        pdf_name = File.basename url
        cache_path = "/var/tmp/#{pdf_name}.txt"

        chdir '/tmp' do
          unless File.exist? cache_path
            logger.info "downloading '#{url}' ..."
            sh "curl -L '#{url}' > st.pdf"
            logger.info "parse pdf by hpdft ..."
            sh "hpdft st.pdf > #{cache_path}"
          else
            logger.info "use cache file. '#{cache_path}'"
          end

          sh "head -2 #{cache_path} | tail -1 > csv_head"
          sh "grep '^#{yyyymm[0...4]}' #{cache_path} > csv_body"
          sh "cat csv_head csv_body | sed -e 's/,//g' -e 's/ /,/g' > st.csv"

          logger.info "importing ..."
          svc = Importers::QuotationImporter.new
          cnt = svc.import_csv 'st.csv'
          logger.info "imported #{cnt} records."
        end
        logger.info 'finish successful'
      end
    end
  end
end

