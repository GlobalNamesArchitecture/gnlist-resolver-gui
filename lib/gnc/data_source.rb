# frozen_string_literal: true

module Gnc
  # DataSource gets data about data resources from resolver
  module DataSource
    def self.fetch
      url = "#{Gnc.conf.internal_resolver_url}/data_sources.json"
      res = JSON.parse(RestClient.get(url))
      res.map { |ds| OpenStruct.new(ds) }.sort_by(&:title)
    end

    def self.find(id)
      fetch.find { |ds| ds.id == id }
    end
  end
end
