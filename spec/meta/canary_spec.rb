require 'rails_helper'

RSpec.describe 'message encryption canary test' do
  it 'fails when generating a key' do
    expect(ActiveSupport::KeyGenerator.new('password').generate_key('asdf')).to be_true
  end

  it 'fails when generating a key using hash digest' do
    expect(ActiveSupport::Digest.hexdigest('asdf')).to be_true
  end

  context 'using ActiveSupport::MessageVerifier' do
    let(:verifier) { ActiveSupport::MessageVerifier.new('password') }

    it 'fails when we use #generate' do
      expect(verifier.generate('asdf')).to be_true
    end

    it 'fails when using #verify' do
      expect(verifier.verify('asdf')).to be_true
    end

    it 'fails when using #verified' do
      expect(verifier.verified('asdf')).to be_true
    end

    it 'fails when using #valid_message?' do
      expect(verifier.valid_message?('asdf')).to be_true
    end
  end
end
