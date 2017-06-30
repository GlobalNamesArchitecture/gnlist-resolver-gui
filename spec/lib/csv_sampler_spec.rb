# frozen_string_literal: true

describe Gnc::CsvSampler do
  describe ".sample" do
    let(:file) { open(File.join(__dir__, "..", "files", "taxonid_as_id.csv")) }
    let(:col_sep) { "," }
    it "creates a sample of rows and headers" do
      res = subject.sample(file, col_sep)
      expect(res).to be_kind_of Hash
      expect(res[:headers]).to eq %w(ID scientificName)
      expect(res[:rows].first.size).to be 2
    end
  end
end
