# frozen_string_literal: true

describe ListMatcher do
  subject { ListMatcher }
  describe ".new" do
    it "creates a new list_matcher" do
      expect(subject.new).to be_kind_of ListMatcher
    end
  end
end
