# frozen_string_literal: true

module Gnc
  # Gnc::ExcelBuilder converts CSV into an Excel file
  class ExcelBuilder
    def initialize(output_path)
      @file = File.split(output_path).last
      @file_path = output_path
      @excel_path = output_path.gsub(/csv$/, "xlsx")
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

    def insert_rows(sheet)
      CSV.open(@file_path, col_sep: "\t").each do |l|
        sheet.add_row(l)
      end
    end
  end
end
