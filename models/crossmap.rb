# frozen_string_literal: true

# Crossmap keeps information about lists to crossmap
class Crossmap < ActiveRecord::Base
  def self.input(token)
    File.join(Gnc::App.settings.root, "uploads", "#{token}.csv")
  end

  def self.output(token, filename)
    match = filename.include?(" ") ? "match " : "match_"
    match_url = File.join("/crossmaps", token)
    match_dir = File.join(Gnc::App.public_folder, match_url)
    FileUtils.mkdir(match_dir) unless File.exist?(match_dir)
    File.join(match_url, "#{match}#{filename}")
  end

  # def transpose(rows_num = 3)
  #   csv = CSV.open(input, "r:utf-8", col_sep: ";")
  #   rows = []
  #   csv.each_with_index do |row, i|
  #     break if i == rows_num
  #     rows << row
  #   end
  #   rows.transpose
  # end
end
