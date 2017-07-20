# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

describe Gnlr do
  describe ".version" do
    it "returns current version" do
      expect(subject.version).to match(/^[\d]+\.[\d]+\.[\d]+$/)
    end
  end

  describe ".logger" do
    it "returns a logger" do
      expect(Gnlr.logger).to be_kind_of Logger
    end
  end

  describe ".logger=" do
    it "creates a new logger" do
      id = Gnlr.logger.object_id
      info = Gnlr.logger.to_s
      Gnlr.logger = Logger.new("/dev/null")
      expect(Gnlr.logger.object_id).to_not eq id
      expect(Gnlr.logger.to_s).to_not eq info
    end
  end

  describe ".env" do
    it "returns app's environment" do
      expect(subject.env).to eq :test
    end
  end

  describe ".prepare_env" do
    context "env is fine" do
      it "returns false" do
        expect(subject.prepare_env).to be true
      end
    end

    context "env cannot make all RACKAPP_.. vars" do
      it "raises error" do
        allow(ENV).to receive(:keys) { [] }
        expect { subject.prepare_env }.to raise_error RuntimeError
      end
    end

    context "env has unknown RACKAPP_.. vars" do
      it "rasies error" do
        ENV["RACKAPP_TOOMANY"] = "yeah"
        expect { subject.prepare_env }.to raise_error RuntimeError
        ENV.delete("RACKAPP_TOOMANY")
      end
    end
  end

  describe ".conf" do
    it "returns app's configuration in OpenStruct" do
      expect(subject.conf).to be_kind_of OpenStruct
    end

    it "has configuration data" do
      expect(subject.conf).to respond_to :database
      expect(subject.conf).to respond_to :session_secret
    end
  end

  describe ".token" do
    it "creates a random token" do
      token = subject.token
      expect(token.size).to be > 8
      expect(token).to be_kind_of String
    end
  end
end

# rubocop:enable all
