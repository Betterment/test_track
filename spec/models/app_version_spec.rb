require 'rails_helper'

RSpec.describe AppVersion do
  it "doesn't allow an empty version number" do
    expect { described_class.new("") }.to raise_error(/must be present/)
  end

  it "can parse an iOS-style version number" do
    expect { described_class.new("1.0.0") }.not_to raise_error
  end

  it "can parse an Android-style versionCode as a string or integer" do
    expect { described_class.new("100") }.not_to raise_error
    expect { described_class.new(100) }.not_to raise_error
  end

  it "doesn't allow 0-prefixes (which would parse as octal)" do
    expect { described_class.new("07") }.to raise_error(/format/)
  end

  it "can collate version numbers numerically by position" do
    expect(described_class.new("0.20")).to be < described_class.new("0.100")
    expect(described_class.new("0.100")).to be > described_class.new("0.20")

    expect(described_class.new("1.2")).to be < described_class.new("2.1")
    expect(described_class.new("2.1")).to be > described_class.new("1.2")

    expect(described_class.new("1.0.0")).to eq described_class.new("1.0.0")

    expect(described_class.new("1.0.0")).not_to eq described_class.new("1.0")
  end

  it "can instantiate from another AppVersion" do
    expect(described_class.new(described_class.new("1.0.0"))).to eq described_class.new("1.0.0")
  end

  describe "#to_s" do
    it "returns the unmolested input value as a string" do
      expect(described_class.new("100.0").to_s).to eq "100.0"

      expect(described_class.new(100).to_s).to eq "100"
    end
  end

  describe "#to_a" do
    it "returns an array of integer parts" do
      expect(described_class.new("1.0.20").to_a).to eq [1, 0, 20]
    end
  end

  describe "#to_pg_array" do
    it "returns a postgresql array literal representation of the version" do
      expect(described_class.new("1.0.20").to_pg_array).to eq '{1,0,20}'
    end
  end

  describe ".from_a" do
    it "ingests an array representation" do
      expect(described_class.from_a([1, 0, 20])).to eq described_class.new("1.0.20")
    end
  end
end
