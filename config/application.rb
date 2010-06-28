require File.expand_path('../boot', __FILE__)
require 'rails/all'

# Auto-require default libraries and those for the current Rails environment.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Radiant
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Add additional load paths for your own custom dirs
    # config.autoload_paths += %W( #{config.root}/extras )

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running
    config.active_record.observers = :user_action_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
    # config.i18n.default_locale = :de
    
    # This is a thin wrapper around Rack::Cache middleware.
    #
    # Comment out this line if you want to turn off all caching, or
    # add options to modify the behavior. In the majority of deployment
    # scenarios it is desirable to leave Radiant's cache enabled and in
    # the default configuration.
    require 'radiant/cache'
    config.middleware.insert_after Rack::Sendfile, Radiant::Cache, :verbose => true

    # Configure generators values. Many other options are available, be sure to check the documentation.
    config.generators do |g|
      g.orm             :active_record
      g.template_engine :haml
      g.test_framework  :rspec, :fixture => false
    end

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    initializer "haml" do
      require 'haml/template'
      require 'sass/plugin'
      Haml::Template.options[:format] = :html5
      Haml::Template.options[:ugly] = Rails.env.production?
    end

    initializer "admin_ui" do
      require 'radiant/admin_ui'
      AdminUI.instance.load_default_nav
    end

    # FIXME: remove this after the extension system works again
    config.autoload_paths += %W(
      #{config.root}/vendor/extensions/archive/app/models
      #{config.root}/vendor/extensions/archive/lib
      #{config.root}/vendor/extensions/textile_filter/lib
    )
    config.to_prepare do
      FileNotFoundPage
      EnvDumpPage
      ArchivePage
      ArchiveYearIndexPage
      ArchiveMonthIndexPage
      ArchiveDayIndexPage
      TextileFilter
      Page.send(:include, TextileTags)
    end

    config.secret_token = "4ac217d6512aae25ea83a25d58c30bed06520ac20ff8040da552f88d3046cf9103c1a7ca21254c9fc64a6f3dd59e00e206e7c410d612390be23d834b48f7b1e8"

    config.action_view.field_error_proc = Proc.new do |html, instance|
      if html !~ /label/
        %{<span class="error-with-field">#{html} <span class="error">&bull; #{[instance.error_message].flatten.first}</span></span>}
      else
        html
      end
    end
  end
end
