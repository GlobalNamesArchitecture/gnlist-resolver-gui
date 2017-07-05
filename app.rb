# frozen_string_literal: true

require "zen-grids"
require "rack/timeout/base"
require "sinatra"
require "sinatra/base"
require "sinatra/flash"
require "sinatra/redirect_with_flash"
require "sinatra/content_for"
require "haml"
require "sass"
require "erb"
require "ostruct"
require "yaml"
require "active_record"
require "csv"
require "rest_client"
require "fileutils"
require "filemagic"
require "gn_crossmap"
require "sucker_punch"
require "axlsx"
require "tmpdir"

require_relative "lib/gnc"
require_relative "lib/gnc/errors"
require_relative "lib/gnc/version"
require_relative "lib/gnc/uploader"
require_relative "lib/gnc/data_source"
require_relative "lib/gnc/job_logger"
require_relative "lib/gnc/file_inspector"
require_relative "lib/gnc/csv_sampler"
require_relative "lib/gnc/resolver"
require_relative "lib/gnc/excel_builder"

Gnc.prepare_load_path
Gnc.prepare_env

log_file = File.join(__dir__, "log", "#{Gnc.env}.log")
Gnc.logger = Logger.new(log_file, 10, 1_024_000)
Gnc.logger.level = Logger::WARN

Gnc.db_connection

require_relative "routes"
require_relative "helpers"

module Gnc
  # Sinatra app namespace
  class App < Sinatra::Application
    # Substitutes a class removed from ActifeRecord 5.x
    # This class takes care of cleaning up ActiveRecord connections
    class ConnectionManagement
      def initialize(app)
        @app = app
      end

      def call(env)
        testing = env["rack.test"]

        status, headers, body = @app.call(env)
        proxy = ::Rack::BodyProxy.new(body) do
          ActiveRecord::Base.clear_active_connections! unless testing
        end
        [status, headers, proxy]
      rescue StandardError
        ActiveRecord::Base.clear_active_connections! unless testing
        raise
      end
    end

    configure do
      register Sinatra::Flash
      helpers Sinatra::RedirectWithFlash

      use Rack::MethodOverride
      use Rack::Session::Cookie, secret: Gnc.conf.session_secret
      use Rack::Timeout, service_timeout: 9_000_000
      use ConnectionManagement

      Compass.add_project_configuration(File.join(File.dirname(__FILE__),
                                                  "config",
                                                  "compass.config"))
      set :scss, Compass.sass_engine_options
      set :bind, "0.0.0.0"
    end
  end
end
