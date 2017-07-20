# frozen_string_literal: true

describe Gnlr::Uploader do
  let(:data) { params("wellformed-semicolon.csv")["checklist_file"] }
  subject { Gnlr::Uploader.new(data) }
  describe ".new" do
    it { is_expected.to be_kind_of Gnlr::Uploader }
  end
end
