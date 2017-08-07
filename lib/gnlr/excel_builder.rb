# frozen_string_literal: true

module Gnlr
  # Gnlr::ExcelBuilder converts CSV into an Excel file
  class ExcelBuilder
    def initialize(output_path)
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
      CSV.open(@file_path, col_sep: "\t").each_with_index do |l|
        if headers[:inputCanonicalForm].nil?
          headers.keys.each { |k| headers[k] = l.index(k.to_s) }
        end

        if l[headers[:matchedEditDistance]].to_i.positive?
          l = show_edit_distance(headers, l)
        end
        sheet.add_row(l)
      end
    end

    def show_edit_distance(headers, row)
      canonicals = @differ.run(row[headers[:inputCanonicalForm]],
                               row[headers[:matchedCanonicalForm]])
      canonicals = canonicals.map do |c|
        rt = Axlsx::RichText.new
        split_by_tags(c).each do |e|
          text, markup = add_style(e)
          rt.add_run(text, markup)
        end
        rt
      end
      row[headers[:inputCanonicalForm]] = canonicals[0]
      row[headers[:matchedCanonicalForm]] = canonicals[1]
      row
    end

    def split_by_tags(str)
      Nokogiri::XML("<root>#{str}</root>").root.children
    end

    def add_style(element)
      case element.name
      when "text"
        [element.text, {b: true}]
      when "subst"
        [element.children.first.text, { b: true, color: "00AA00" }]
      when "del"
        [element.children.first.text, { strike: true,
                                        color: "AA0000" }]
      when "ins"
        [element.children.first.text, { b: true, color: "00AA00" }]
      end
    end
  end
end
