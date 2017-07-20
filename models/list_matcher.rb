# frozen_string_literal: true

# ListMatcher keeps information about lists used for matching names
class ListMatcher < ActiveRecord::Base
  def self.input(token)
    File.join(Gnlr::App.settings.root, "uploads", "#{token}.csv")
  end

  def self.output(token, filename)
    match = filename.include?(" ") ? "match " : "match_"
    match_url = File.join("/downloads", token)
    match_dir = File.join(Gnlr::App.public_folder, match_url)
    FileUtils.mkdir(match_dir) unless File.exist?(match_dir)
    File.join(match_url, "#{match}#{filename}")
  end
end
