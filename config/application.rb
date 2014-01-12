require File.expand_path('../boot', __FILE__)

require "rails"

%w(
  active_model
  action_controller
  action_mailer
  rails/test_unit
  sprockets
  sequel_rails
).each do |framework|
  begin
    require "#{framework}/railtie"
  rescue LoadError
  end
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module CoinProfit
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.generators do |g|
      g.orm :sequel
      g.test_framework :rspec
    end
    config.sequel.schema_format = :ruby

    initializer 'app.sequel_setup', after: 'sequel.connect' do
      Sequel::Model.db.extension :pagination
      Sequel::Model.plugin :timestamps, update_on_create: true
      Sequel::Model.plugin :association_proxies
      Sequel::Model.plugin :active_model
    end
  end
end
