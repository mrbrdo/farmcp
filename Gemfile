source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

gem 'pry-rails'

# Platform-dependent
platforms(:jruby)   { gem 'jdbc-postgres' }
platforms(:ruby)    { gem 'pg' }
group :production do
  platforms(:jruby) { gem 'therubyrhino' }
  platforms(:ruby)  { gem "therubyracer", :require => 'v8' }
end
group :development do
  platforms(:jruby) { gem 'theine' }
end

# DB
gem 'sequel-rails'

group :development, :test do
  gem 'database_cleaner'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'spork', '~> 1.0rc'
  gem 'guard-rspec', require: false
  gem 'guard-spork'
end
