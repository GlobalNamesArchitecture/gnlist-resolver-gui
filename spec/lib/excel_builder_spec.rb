# frozen_string_literal: true

describe Gnlr::ExcelBuilder do
  let(:output_dir) { File.join(Dir.tmpdir, "deleteme") }
  let(:file) { "output.csv" }
  let(:output_path) { File.join(output_dir, file) }


  subject { Gnlr::ExcelBuilder.new(output_path) }
  describe ".new" do
    it { is_expected.to be_kind_of Gnlr::ExcelBuilder }
  end

  describe "#build" do
    let(:test_output) { File.join(__dir__, "..", "files", file) }
    let(:excel_output) { output_path.gsub(/csv$/, "xlsx") }

    it "finds csv file by token and converts it to Excel version" do
      FileUtils.rm_rf(output_dir)
      FileUtils.mkdir(output_dir)
      FileUtils.cp(test_output, output_dir)
      subject.build
      expect(File.exist?(excel_output)).to be true
      expect(Gnlr::FileInspector::FM.file(excel_output)).to match("Microsoft")
      FileUtils.rm_rf(output_dir)
    end
  end
end
