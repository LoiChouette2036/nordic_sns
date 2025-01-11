require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # Uncomment and replace with your CDN or asset server URL if applicable.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the local file system (see config/storage.yml for options).
  # Change :local to :amazon or any other service you use for ActiveStorage in production.
  config.active_storage.service = :local

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  # Uncomment if you have a health check path.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))

  # Log level: Use :info for production to reduce log size. Use :debug for debugging.
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations in production.
  config.active_support.report_deprecations = false

  # Use memory cache store or configure a distributed cache like Redis.
  config.cache_store = :memory_store

  # Use a durable Active Job backend (e.g., Sidekiq for queues).
  config.active_job.queue_adapter = :inline

  # Ignore bad email addresses and do not raise email delivery errors.
  # Configure properly for email sending in production.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { host: "yggdrasilrealm.xyz" }
  # Uncomment and configure SMTP settings for email sending.
  # config.action_mailer.smtp_settings = {
  #   user_name: Rails.application.credentials.dig(:smtp, :user_name),
  #   password: Rails.application.credentials.dig(:smtp, :password),
  #   address: "smtp.example.com",
  #   port: 587,
  #   authentication: :plain
  # }

  # Enable locale fallbacks for I18n.
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Enable DNS rebinding protection and other `Host` header attacks.
  config.hosts = [
    "yggdrasilrealm.xyz", # Allow requests from your domain
    /.*\.yggdrasilrealm\.xyz/ # Allow requests from subdomains
  ]
end
