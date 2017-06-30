# frozen_string_literal: true

describe Gnc::FileInspector do
  let(:files) { File.join(__dir__, "..", "files") }
  let(:file) { open(File.join(files, "taxonid_as_id.csv")) }

  describe ".inspect" do
    it "inspects a file" do
      res = subject.inspect(file)
      expect(res).to eq(is_csv: true, col_sep: ",", encoding: "UTF-8")
    end

    context "encodings" do
      let(:utf16) { open(File.join(files, "utf16.csv")) }
      let(:latin1) { open(File.join(files, "latin1.csv")) }
      it "detects latin1 encoding" do
        file = open(latin1)
        res = subject.inspect(file)
        expect(res).to eq(is_csv: true, col_sep: ",",
                          encoding: "ISO-8859-1:UTF-8")
      end

      it "detects utf16 encoding" do
        file = open(utf16)
        res = subject.inspect(file)
        expect(res).to eq(is_csv: true, col_sep: ",",
                          encoding: "UTF-16:UTF-8")
      end
    end

    context "not cvs files" do
      it "returns non-csv result" do
        %w(file.html file.pdf file.xlsx).each do |f|
          file = open(File.join(files, f))
          res = subject.inspect(file)
          expect(res).to eq(is_csv: false, col_sep: "", encoding: "")
        end
      end
    end
  end
end
