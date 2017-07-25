# frozen_string_literal: true

require "rack/reverse_proxy"

module Gnlr
  # Sinatra App namespace
  class App < Sinatra::Application
    post "/upload" do
      begin
        uploader = Gnlr::Uploader.new(params["file-upload"])
        list_matcher = uploader.save_list_file
        list_matcher.token
      rescue Gnlr::FileTypeError
        "FAIL"
      end
    end

    get "/list_matchers/:token" do
      content_type :json
      ListMatcher.find_by_token(params[:token]).to_json
    end

    put "/list_matchers" do
      params = JSON.parse(request.body.read, symbolize_names: true)
      logger.info params
      list_matcher = ListMatcher.find_by_token(params[:token])
      filtered_params = params.select do |k, _|
        %i[data_source_id alt_headers stop_trigger].include? k
      end
      list_matcher.update(filtered_params)
      list_matcher.save ? "OK" : nil
    end

    get "/resolver/:token" do
      content_type :json
      Gnlr::Resolver.perform_async(params[:token])
      { status: "OK" }.to_json
    end

    get "/stats/:token" do
      content_type :json
      cm = ListMatcher.find_by_token(params[:token])
      cm.stats.to_json
    end

    if ENV["ASSET_HOST"]
      use Rack::ReverseProxy do
        reverse_proxy_options preserve_host: false
        reverse_proxy %r{\A\/\z}, "http://#{ENV['ASSET_HOST']}/"
        reverse_proxy(/\A(.*\.(js|css))\z/, "http://#{ENV['ASSET_HOST']}/$1")
      end
    else
      get "/" do
        send_file File.expand_path("index.html", settings.public_folder)
      end
    end
  end
end
