Vish::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # do not send emails
  config.action_mailer.perform_deliveries = false 
  config.action_mailer.raise_delivery_errors = true

  #default host for routes
  Rails.application.routes.default_url_options[:host] = 'localhost:3000'

  #Autoload scorm gem
  if ENV['FORCE_LOCAL_SCORM']
    config.autoload_paths += %W(#{config.root}/../scorm/lib)
    ActiveSupport::Dependencies.explicitly_unloadable_constants << 'scorm'
  end
 
end
