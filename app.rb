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
require "gn_list_resolver"
require "sucker_punch"
require "axlsx"
require "tmpdir"
require "damerau-levenshtein"

require_relative "lib/gnlr"
require_relative "lib/gnlr/errors"
require_relative "lib/gnlr/version"
require_relative "lib/gnlr/uploader"
require_relative "lib/gnlr/data_source"
require_relative "lib/gnlr/job_logger"
require_relative "lib/gnlr/file_inspector"
require_relative "lib/gnlr/csv_sampler"
require_relative "lib/gnlr/resolver"
require_relative "lib/gnlr/excel_builder"

Gnlr.prepare_load_path
Gnlr.prepare_env

log_file = File.join(__dir__, "log", "#{Gnlr.env}.log")
Gnlr.logger = Logger.new(log_file, 10, 1_024_000)
Gnlr.logger.level = Logger::WARN

Gnlr.db_connection

require_relative "routes"
require_relative "helpers"

module Gnlr
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
      use Rack::Session::Cookie, secret: Gnlr.conf.session_secret
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
