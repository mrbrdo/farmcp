source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'

gem 'sass-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'haml-rails'

gem 'pry-rails'
gem 'mina'
gem 'mina-extras', github: "mrbrdo/mina-extras"
gem 'puma'
gem 'dotenv-rails'
gem 'nokogiri'
gem 'mechanize'

gem 'foundation-rails'

# Platform-dependent
platforms(:jruby)   { gem 'jdbc-sqlite3' }
platforms(:ruby)    { gem 'sqlite3' }
group :production do
  platforms(:jruby) { gem 'therubyrhino' }
  platforms(:ruby)  { gem "therubyracer", :require => 'v8' }
end

# DB
gem 'sequel-rails'
