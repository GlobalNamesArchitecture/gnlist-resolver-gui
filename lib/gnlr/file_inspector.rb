# frozen_string_literal: true

module Gnlr
  # Determines what kind of file was uploaded
  module FileInspector
    EMPTY_RESULT = ["", 0, ""].freeze
    FM = ::FileMagic.new(FileMagic::MAGIC_NONE)

    class << self
      def inspect(file)
        col_sep, fields, enc = inspect_content(file)
        if col_sep != "" && fields.positive?
          { is_csv: true, col_sep: col_sep, encoding: enc }
        else
          { is_csv: false, col_sep: "", encoding: "" }
        end
      end

      private

      def inspect_content(file)
        res = FM.file(file.path)
        enc = encoding(res)
        csvlike?(res) && enc ? csv_properties(file, enc) : EMPTY_RESULT
      rescue CSV::MalformedCSVError, ArgumentError
        EMPTY_RESULT
      end

      def csvlike?(inspect_result)
        words = inspect_result.split(/\s+/).map(&:downcase)
        inspect_result =~ /\btext\b/ &&
          (words - %w[html xml]).size == words.size
      end

      def csv_properties(file, enc)
        col_sep = separator(file, enc)
        csv = CSV.open(file.path, col_sep: col_sep, encoding: enc)
        fields_num = csv.first.size
        csv.close
        [col_sep, fields_num, enc]
      end

      def encoding(inspect_result)
        case inspect_result
        when /UTF-8|ASCII/
          "UTF-8"
        when /UTF-16/
          "UTF-16:UTF-8"
        when /8859/
          "ISO-8859-1:UTF-8"
        end
      end

      def separator(file, enc)
        f = open(file.path, encoding: enc)
        line = f.gets.strip
        f.close
        res = [[";", 1], [",", 0], ["\t", 2]].map do |s, weight|
          [line.count(s), weight, s]
        end
        res = res.sort.last
        res.first.zero? ? "\t" : res.last
      end
    end
  end
end
