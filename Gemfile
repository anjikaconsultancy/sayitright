source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'
# gem 'rails', '~> 6.0.2'
gem 'rails', '~> 5.2', '>= 5.2.4.2'

gem 'puma'#, '~>1.6'

# Gems used only for assets and not required
# in production environments by default.
# group :assets do
  gem 'sass-rails'#,             '3.2.5'
  gem 'uglifier'#,               '~>1.0'
  gem 'coffee-rails'#,           '~>3.2'
  gem 'compass-rails', github: 'Compass/compass-rails'

  # gem 'compass-rails',          '1.0.3'
  gem 'zurb-foundation'#,        '~>3.2.3'
  gem 'foundation-rails'
  gem 'autoprefixer-rails' 
  gem 'handlebars_assets'#,      '0.15' #new version breaks temaplte loading for now?
# end

# Need to force this to older version or heroku push fails (becuse of current fog gem, update should fix it)
# gem 'net-scp',                '1.0.4' 

# Needs old version without ruby 2+
# gem 'net-ssh',                '2.9.2'

# Needs newer version than sanitize requests or wont compile
gem 'nokogiri'#,               '~>1.6'

gem 'mongoid', '~> 7.0.5'

# gem 'strong_parameters'#,      '~>0.1'
# gem 'mongoid'#,                '~>3.1.0'
gem 'rabl'#,                   '~>0.8.0'
# gem 'kaminari'#,               '~>0.13'
gem 'kaminari-mongoid'

gem 'oauth'#,                  '~>0.4'
gem 'oauth2'#,                 '~>0.7'
gem 'devise'#,                 '~>2.1'
gem 'heroku-api'#,             '~>0.3'
gem 'sanitize'#,               '~>2.0.0'
gem 'chronic'#,                '~>0.7'
# gem 'fog'#,                    '~>1.3'
gem 'mustache'#,               '~>0.99.4'
# gem 'newrelic_rpm'#,           '~>3.5'
gem 'delayed_job'#,            '3.0.5'
gem 'delayed_job_mongoid'#,    '2.3.0'
gem 'zencoder'#,               '~> 2.5'
gem 'mime-types'#,             '~> 1.19'
gem 'select2-rails'

gem 'bson_ext'
# gem "moped", github: "mongoid/moped"
gem 'bootsnap', '~> 1.4', '>= 1.4.6'
gem 'fog-aws'
gem 'dotenv-rails', groups: [:development, :test]
gem 'jquery-rails'
gem 'turbolinks'
gem 'backbone-on-rails'
gem 'lodash-rails'
gem 'rails-backbone-generator'

# This breaks our assets
# gem 'rails_12factor', group: :production

group :test do
  gem 'test-unit'
  gem 'ruby-prof'
  gem 'database_cleaner'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2' 
  gem 'pry-rails'
end
