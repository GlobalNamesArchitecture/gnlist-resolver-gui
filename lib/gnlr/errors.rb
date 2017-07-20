# frozen_string_literal: true

module Gnlr
  # An error for cases when an uploaded file is not in an accepted CSV format
  class FileTypeError < RuntimeError; end
end
