# frozen_string_literal: true

describe Crossmap do
  subject { Crossmap }
  describe ".new" do
    it "creates a new crossmap" do
      expect(subject.new).to be_kind_of Crossmap
    end
  end
end
