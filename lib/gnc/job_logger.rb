# frozen_string_literal: true

module Gnc
  # Redirects logs from crossmapper
  class JobLogger
    def initialize(token)
      @token = token
      @output = File.open(File.join("tmp", "gnc_#{token}.log"), "w:utf-8")
    end

    def info(log)
      @output.write(log + "\n")
    end
  end
end
