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
    config.assets.precompile += %w( dashboard.css dashboard.js )
    config.autoload_paths += %W(#{config.root}/app/services)

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
