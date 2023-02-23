require 'rails_helper'

RSpec.describe GithubSearch do
  describe '#configured?' do
    it 'returns true when ENV variable set' do
      with_env('GITHUB_ORGANIZATION' => 'Betterment') do
        expect(described_class.configured?).to eq(true)
      end
    end

    it 'returns false when ENV variable unset' do
      with_env('GITHUB_ORGANIZATION' => nil) do
        expect(described_class.configured?).to eq(false)
      end
    end
  end

  describe '#github_organization' do
    it 'returns value from ENV when set' do
      with_env('GITHUB_ORGANIZATION' => 'Betterment') do
        expect(described_class.github_organization).to eq('Betterment')
      end
    end

    it 'returns nil when ENV unset' do
      with_env('GITHUB_ORGANIZATION' => nil) do
        expect(described_class.github_organization).to be_nil
      end
    end
  end

  describe '#build_split_search_url' do
    it 'raises when github search unconfigured' do
      split = instance_double(Split, name: 'blah_enabled')

      with_env('GITHUB_ORGANIZATION' => nil) do
        expect { described_class.build_split_search_url(split) }.to raise_error(/Cannot build split search url/)
      end
    end

    it 'returns proper url' do
      org_name = 'Betterment'
      split_name = 'blah_enabled'
      split = instance_double(Split, name: split_name)

      with_env('GITHUB_ORGANIZATION' => org_name) do
        expect(described_class.build_split_search_url(split)).to eq("https://github.com/search?q=org%3A#{org_name}+#{split_name}&type=code")
      end
    end
  end
end
