# frozen_string_literal: true

describe Gnlr::DataSource do
  subject { Gnlr::DataSource }

  describe ".fetch" do
    subject { Gnlr::DataSource.fetch }
    it "returns data source information from GN resolver" do
      expect(subject).to be_kind_of Array
    end

    it "sorts results by title" do
      sorted_titles = subject.map(&:title).sort
      expect(subject.map(&:title)).to eq sorted_titles
    end
  end

  describe ".find" do
    it "returns data source by id" do
      expect(subject.find(1)).to be_kind_of OpenStruct
    end
  end
end
