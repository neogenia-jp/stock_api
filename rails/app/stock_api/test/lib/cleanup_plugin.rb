require 'database_rewinder'

DatabaseCleaner = DatabaseRewinder
module CleanupPlugin
  def setup
    super
    DatabaseCleaner.strategy = [:truncation, except: view_list]
    DatabaseCleaner.clean_all
  end
  

  def teardown
    super
  ensure
    #DEPRECATION WARNING: #tables currently returns both tables and views. This behavior is deprecated and will be changed with Rails 5.1 to
    #only return tables. Use #data_sources instead. (called from teardown at /var/data/test/lib/cleanup_plugin.rb:12)
    #という警告がでるが、これはその状態で正しい（truncate対象にviewは不要）ので問題ない
    DatabaseCleaner.clean
  end

  private
  def view_list
    @view_list ||= ActiveRecord::Base.connection.views
  end
end
