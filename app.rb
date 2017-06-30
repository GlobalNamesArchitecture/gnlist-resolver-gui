# frozen_string_literal: true

require "zen-grids"
require "rack/timeout/base"
require "sinatra"
require "sinatra/base"
require "sinatra/flash"
require "sinatra/redirect_with_flash"
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
    configure do
      register Sinatra::Flash
      helpers Sinatra::RedirectWithFlash

      use Rack::MethodOverride
      use Rack::Session::Cookie, secret: Gnc.conf.session_secret

      use Rack::Timeout, service_timeout: 9_000_000

      Compass.add_project_configuration(File.join(File.dirname(__FILE__),
                                                  "config",
                                                  "compass.config"))
      set :scss, Compass.sass_engine_options
      set :bind, "0.0.0.0"
    end
  end
end
