# frozen_string_literal: true

module Gnlr
  # Gnlr::ExcelBuilder converts CSV into an Excel file
  class ExcelBuilder
    def initialize(list_matcher, output_path)
      @list_matcher = list_matcher
      @file = File.split(output_path).last
      @file_path = output_path
      @excel_path = excel_path(output_path)
      @differ = DamerauLevenshtein::Differ.new
    end

    def build
      tmp_file = @excel_path + ".tmp"
      xl = ::Axlsx::Package.new
      wb = xl.workbook
      wb.add_worksheet(name: "Match Result") do |sheet|
        insert_rows(sheet)
      end
      xl.serialize(tmp_file)
      FileUtils.mv(tmp_file, @excel_path)
    end

    private

    def excel_path(path)
      path.gsub(File.extname(path), ".xlsx")
    end

    def insert_rows(sheet)
      headers = { inputCanonicalForm: nil, matchedCanonicalForm: nil,
                  matchedEditDistance: nil }
      percent = @list_matcher.stats["total_records"] / 100
      CSV.open(@file_path, col_sep: "\t").each_with_index do |l, i|
        add_row(headers, sheet, l, i, percent)
      end
      update_stats(@list_matcher.stats["total_records"])
    end

    def add_row(headers, sheet, row, index, percent)
      if headers[:inputCanonicalForm].nil?
        headers.keys.each { |k| headers[k] = row.index(k.to_s) }
      end
      update_stats(index) if (index % percent).zero?
      row = handle_edit_distance(headers, row)
      sheet.add_row(row)
    end

    def handle_edit_distance(headers, row)
      return row unless row[headers[:matchedEditDistance]].to_i.positive?
      show_edit_distance(headers, row)
    end

    def update_stats(index)
      @list_matcher.stats["excel_rows"] = index
      @list_matcher.save!
    end

    def show_edit_distance(headers, row)
      canonicals = @differ.run(row[headers[:inputCanonicalForm]].to_s,
                               row[headers[:matchedCanonicalForm]].to_s)
      canonicals = update_canonicals(canonicals)
      row[headers[:inputCanonicalForm]] = canonicals[0]
      row[headers[:matchedCanonicalForm]] = canonicals[1]
      row
    end

    def update_canonicals(canonicals)
      canonicals.map do |c|
        rt = Axlsx::RichText.new
        split_by_tags(c).each do |e|
          text, markup = add_style(e)
          rt.add_run(text, markup)
        end
        rt
      end
    end

    def split_by_tags(str)
      Nokogiri::XML("<root>#{str}</root>").root.children
    end

    # rubocop:disable Metrics/MethodLength

    def add_style(element)
      case element.name
      when "text"
        [element.text, { b: true }]
      when "subst"
        [element.children.first.text, { b: true, color: "00AA00" }]
      when "del"
        [element.children.first.text, { strike: true,
                                        color: "AA0000" }]
      when "ins"
        [element.children.first.text, { b: true, color: "00AA00" }]
      end
    end

    # rubocop:enable all
  end
end
