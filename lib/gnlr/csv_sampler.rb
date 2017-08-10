# frozen_string_literal: true

module Gnlr
  # Creates a sample of data from a csv file
  module CsvSampler
    class << self
      def sample(file, col_sep)
        quot = col_sep == "\t" ? "\x00" : '"'
        csv = CSV.new(open(file, "r:utf-8"), col_sep: col_sep,
                                             quote_char: quot)
        headers, rows = traverse_csv(csv)
        { headers: headers, rows: rows.sort_by { |r| r.compact.size }.
          reverse[0..9] }
      rescue CSV::MalformedCSVError
        { headers: [], rows: [] }
      end

      private

      def traverse_csv(csv)
        headers = nil
        rows = []
        csv.each_with_index do |r, i|
          i.zero? ? (headers = prepare_headers(r)) : rows << r
          break if i > 499
        end
        [headers, rows]
      end

      def prepare_headers(headers)
        headers.map do |h|
          h.to_s.strip.delete("\u{feff}")
        end
      end
    end
  end
end
