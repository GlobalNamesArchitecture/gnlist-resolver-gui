# frozen_string_literal: true

module Gnc
  # Gnc::Uploader saves scinames list file on a local machine
  class Uploader
    def initialize(params)
      @params = OpenStruct.new(params)
      @list_file = nil
    end

    def save_list_file
      res = FileInspector.inspect(@params.tempfile)
      raise(GncFileTypeError, "Not a CSV file") unless res[:is_csv]
      token = Gnc.token
      copy_file(token, res[:encoding])
      save_db(res[:col_sep], token)
    end

    private

    def copy_file(token, enc)
      open(Crossmap.input(token), "w") do |input|
        f = open(@params.tempfile.path, encoding: enc)
        input.write(f.read)
        f.close
      end
    end

    def save_db(col_sep, token)
      sample = Gnc::CsvSampler.sample(Crossmap.input(token), col_sep)
      Crossmap.create(filename: @params.filename,
                      input: Crossmap.input(token),
                      output: Crossmap.output(token, @params.filename),
                      data_source_id: 1, # TODO: brittle
                      col_sep: col_sep,
                      input_sample: sample,
                      token: token)
    end
  end
end
