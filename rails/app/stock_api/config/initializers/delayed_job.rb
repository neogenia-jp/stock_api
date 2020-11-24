Delayed::Worker.tap do |w|
  # worker設定
  # ログ出力先
  w.logger = ActiveSupport::Logger.new(File.join(Rails.root, 'log', "#{Rails.env}_delayed_job.log"))

  # queueのポーリング間隔(秒)
  w.sleep_delay = 8

  # retry回数
  w.max_attempts = 3
end

# workerのポーリングのログ出力を無くす
# ポーリング以外の
#  JOB実行時のエラー
#  JOB実行に関するキュー操作（デキューのログ）
# は出力される
unless ENV['ENABLE_DELAYED_JOB_RESERVE_LOG']
  module DelayedJobEx
    # reserveメソッドをフックして一時的にログレベルを変えてオリジナルのreserveを呼び出す
    def reserve(*)
      # 間に任意の処理を挟んでも良いが、その場合はsuperの戻りをメソッドの戻り値として返すこと
      previous_level = ::ActiveRecord::Base.logger.level
      ::ActiveRecord::Base.logger.level = Logger::WARN if previous_level < Logger::WARN
      super
    ensure
      ::ActiveRecord::Base.logger.level = previous_level
    end
  end

  module Delayed
    module Backend
      module ActiveRecord
        class Job
          class << self
            prepend DelayedJobEx
          end
        end
      end
    end
  end
end
