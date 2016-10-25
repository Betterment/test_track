require 'rails_helper'

RSpec.describe CorsSupport, type: :concern do
  let(:cors_controller_class) { Class.new(UnauthenticatedApiController) { include CorsSupport } }
  subject { cors_controller_class.new }

  before(:each) do
    # HTTP_ORIGIN includes protocol and host
    allow(subject).to receive(:origin).and_return("https://my.domain.tld")
  end

  def allow_hosts(hosts)
    allow(subject).to receive(:whitelisted_hosts).and_return(hosts.join(','))
  end

  describe "cors_support" do
    it "allows from identical URI" do
      allow_hosts %w(https://my.domain.tld)

      expect(subject.send(:cors_allowed?)).to be_truthy
    end

    it "allows from identical host" do
      allow_hosts %w(my.domain.tld)

      expect(subject.send(:cors_allowed?)).to be_truthy
    end

    it "allows from matching, partial host" do
      allow_hosts %w(.domain.tld)

      expect(subject.send(:cors_allowed?)).to be_truthy
    end

    it "allows if any one domain matches" do
      allow_hosts %w(no.domain.tld nope.domain.tld .domain.tld)

      expect(subject.send(:cors_allowed?)).to be_truthy
    end

    it "denies if no domain matches" do
      allow_hosts %w(no.domain.tld nope.domain.tld)

      expect(subject.send(:cors_allowed?)).to be_falsey
    end
  end
end
