# frozen_string_literal: true

module Gnlr
  # Performs name-matching using given list of names and
  # a reference data source
  class Resolver
    include SuckerPunch::Job
    workers 4

    def perform(token)
      ActiveRecord::Base.connection_pool.with_connection do
        begin
          resolve(token)
          make_excel_output(token)
          logger.info "Successful name-matching with #{token}"
        rescue GnCrossmapError => e
          logger.error e.message
        end
      end
    end

    private

    def resolve(token)
      list_matcher, opts = params(token)
      @output = opts[:output]
      GnCrossmap.run(opts) do |stats|
        %i[ingestion_start resolution_start
           resolution_stop ingestion_span resolution_span].each do |t|
          stats[t] = stats[t].to_f unless stats[t].nil?
        end
        list_matcher.update(stats: stats)
        "STOP" if ListMatcher.find_by_token(token).stop_trigger
      end
    end

    def params(token)
      list_matcher = ListMatcher.find_by_token(token)
      output = File.join(Gnlr::App.public_folder, list_matcher.output)
      alt_headers = list_matcher.alt_headers ? list_matcher.alt_headers : []
      opts = { input: list_matcher.input, output: output,
               data_source_id: list_matcher.data_source_id,
               resolver_url: Gnlr.conf.internal_resolver_url +
                             "/name_resolvers.json",
               skip_original: false, alt_headers: alt_headers }
      [list_matcher, opts]
    end

    def make_excel_output(token)
      list_matcher, opts = params(token)
      Gnlr::ExcelBuilder.new(opts[:output]).build
      stats = list_matcher.stats.merge(status: "done")
      list_matcher.update(stats: stats)
    end
  end
end
