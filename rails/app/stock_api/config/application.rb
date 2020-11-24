require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module StockApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Active Jobのアダプタ設定
    config.active_job.queue_adapter = :delayed_job

    # modelの階層化
    config.autoload_paths += Dir[Rails.root.join('app/models/**/')]

    # service layer path
    config.autoload_paths += Dir[Rails.root.join('app/services/')]
    #config.autoload_paths += Dir[Rails.root.join('app/services/concerns/')]

    config.time_zone = 'Asia/Tokyo'

    ## 日本語化
    # I18n.enforce_available_locales = true
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :ja
  end
end
