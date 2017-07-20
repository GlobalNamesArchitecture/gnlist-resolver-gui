# frozen_string_literal: true

module Gnlr
  # Sinatra App name space
  class App < Sinatra::Application
    helpers do
      include Sinatra::RedirectWithFlash
      include Rack::Utils
      alias_method :h, :escape_html
    end
  end
end
