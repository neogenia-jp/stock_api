class BaseService
  def logger
    Rails.logger
  end

#  def self.xbrldb
#    db_config = Rails.configuration.database_configuration
#    db_config[Rails.env]['xbrldb']
#  end
#
#  def self.us_stocks_db
#    db_config = Rails.configuration.database_configuration
#    db_config[Rails.env]['us_stocks_db']
#  end
#
#  def xbrldb
#    BaseService.xbrldb
#  end
#
#  def us_stocks_db
#    BaseService.us_stocks_db
#  end

  def with_transaction
    ActiveRecord::Base.transaction do
      yield
    end
  end
end
