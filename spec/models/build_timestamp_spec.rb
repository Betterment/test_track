require 'rails_helper'

describe BuildTimestamp do
  it "is valid with valid args" do
    expect(described_class.new(timestamp: "2019-04-16T14:35:30Z")).to be_valid
  end

  it "is invalid with no build timestamp" do
    expect(described_class.new(timestamp: "")).to be_invalid
  end

  it "is invalid with a non-ISO date" do
    expect(described_class.new(timestamp: "2019-04-16 10:38:08 -0400")).to be_invalid
  end

  it "is valid with an ISO date with millis" do
    expect(described_class.new(timestamp: "2019-04-16T14:35:30.123Z")).to be_valid
  end

  it "is invalid with an ISO date without seconds" do
    expect(described_class.new(timestamp: "2019-04-16T14:35Z")).to be_invalid
  end
end
