# frozen_string_literal: true

module Gnlr
  # Gnlr::ExcelBuilder converts CSV into an Excel file
  class ExcelBuilder
    def initialize(output_path)
      @file = File.split(output_path).last
      @file_path = output_path
      @excel_path = excel_path(output_path)
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
      CSV.open(@file_path, col_sep: "\t").each do |l|
        sheet.add_row(l)
      end
    end
  end
end
