source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


gem 'rails', '~> 5.2'
gem 'bootsnap', '~> 1.3.2'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'jbuilder', '~> 2.5'
gem 'dotenv-rails'
gem 'jquery-rails'
gem 'bootstrap', '~> 4.3.1'
gem "bootstrap_form", ">= 4.0.0.alpha1"
gem 'validates_timeliness', '~> 5.0.0.alpha3'
gem 'roo'
gem 'uuidtools'
gem 'devise'
gem 'devise_invitable'
gem 'pundit'
gem 'sentry-raven'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'faker'
  gem 'pry-rails'
  gem 'rb-readline'

  gem 'factory_bot_rails'
  gem 'rspec-rails'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  gem 'capistrano', '~> 3.10'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-passenger'
  gem 'capistrano-rails-console', require: false
end

group :test do
  gem 'capybara'
  gem 'launchy'
  gem 'shoulda-matchers', '~> 3.1'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
