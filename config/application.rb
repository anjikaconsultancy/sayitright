require_relative 'boot'

#require "rails/all"

# Add this require instead of "rails/all":
require "rails"

# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Remove or comment out ActiveRecord and ActiveStorage:
# require "active_record/railtie"
# require "active_storage/engine"


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Sirn
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.generators do |g|
		  g.orm :mongoid
		end
    config.mongoid.preload_models = false
    config.action_controller.include_all_helpers = true
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end

# https://app.compose.com/session/new
# thukral.d@gmail.com
# qwertyui!@#$%^&