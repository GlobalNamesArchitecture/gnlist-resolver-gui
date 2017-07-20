# frozen_string_literal: true

module Gnlr
  # Redirects logs from the name matching gem
  class JobLogger
    def initialize(token)
      @token = token
      @output = File.open(File.join("tmp", "gnlr_#{token}.log"), "w:utf-8")
    end

    def info(log)
      @output.write(log + "\n")
    end
  end
end
