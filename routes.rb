# frozen_string_literal: true

require "rack/reverse_proxy"

module Gnc
  # Sinatra App namespace
  class App < Sinatra::Application
    if ENV["ASSET_HOST"]
      use Rack::ReverseProxy do
        reverse_proxy_options preserve_host: false
        reverse_proxy(
          %r{^\/assets(\/.*)$},
          "http://#{ENV['ASSET_HOST']}/static$1"
        )
      end
    end

    get "/css/:filename.css" do
      scss :"sass/#{params[:filename]}"
    end

    get "/" do
      haml :home
    end

    post "/upload" do
      begin
        uploader = Gnc::Uploader.new(params["file-upload"])
        crossmap = uploader.save_list_file
        crossmap.token
      rescue GncFileTypeError
        "FAIL"
      end
    end

    get "/crossmaps/:token" do
      content_type :json
      crossmap = Crossmap.find_by_token(params[:token]).to_json
      puts crossmap
      crossmap
    end

    put "/crossmaps" do
      params = JSON.parse(request.body.read, symbolize_names: true)
      logger.info params
      crossmap = Crossmap.find_by_token(params[:token])
      crossmap_params = params.select do |k, _|
        %i[data_source_id alt_headers stop_trigger].include? k
      end
      crossmap.update(crossmap_params)
      crossmap.save ? "OK" : nil
    end

    get "/resolver/:token" do
      content_type :json
      Gnc::Resolver.perform_async(params[:token])
      { status: "OK" }.to_json
    end

    get "/stats/:token" do
      content_type :json
      cm = Crossmap.find_by_token(params[:token])
      cm.stats.to_json
    end
  end
end
