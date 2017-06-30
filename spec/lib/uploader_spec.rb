# frozen_string_literal: true

describe Gnc::Uploader do
  let(:data) { params("wellformed-semicolon.csv")["checklist_file"] }
  subject { Gnc::Uploader.new(data) }
  describe ".new" do
    it { is_expected.to be_kind_of Gnc::Uploader }
  end
end
