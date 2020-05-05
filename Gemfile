source 'https://rubygems.org'
# ruby '1.9.3'
ruby '2.6.3'

gem 'rails', '~> 5.2', '>= 5.2.4.2'
# gem 'rails', '3.2.17'
gem 'puma'
# gem 'json'##, '1.8.6'
# Gems used only for assets and not required
# in pruction environments by default.
# group :assets do
  # gem 'sass'
gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'
# gem 'compass-rails'
gem 'compass-rails', '~> 3.0', '>= 3.0.2'
gem 'zurb-foundation'
gem 'foundation-icons-sass-rails'
gem 'handlebars_assets' #new version breaks temaplte loading for now?
# end

# Need to force this to older version or heroku push fails (becuse of current fog gem, update should fix it)
gem 'net-scp'

# Needs old version without ruby 2+
gem 'net-ssh'

# Needs newer version than sanitize requests or wont compile
gem 'nokogiri'

# gem 'strong_parameters',      '~>0.1'
gem 'mongoid'
gem 'rabl'
gem 'kaminari'
gem 'oauth'
gem 'oauth2'
gem 'devise'
gem 'heroku-api'
gem 'sanitize'
gem 'chronic'
# gem 'fog'\\
gem 'fog-aws'
gem 'mustache', '~> 1.1'
# gem 'newrelic_rpm',           '~>3.5'
gem 'delayed_job'
gem 'delayed_job_mongoid'
gem 'zencoder'
gem 'mime-types'
gem 'select2-rails'
gem 'dotenv-rails', groups: [:development, :test]
gem 'bootsnap', require: false

gem 'listen'
gem 'kaminari-mongoid', '~> 0.1.0'

# This breaks our assets
# gem 'rails_12factor', group: :production

group :test do
  gem 'test-unit'
  gem 'ruby-prof'
  gem 'database_cleaner'
end

group :development do
  gem 'pry-rails'
end
gem 'newrelic_rpm', '~> 5.2', '>= 5.2.0.345'
gem 'rails_12factor', group: :production

