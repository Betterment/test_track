namespace :test_track do
  task :vendor_deps do
    FileUtils.module_eval do
      cd "vendor/gems" do
        rm_r 'ruby_spec_helpers'
        `git clone --depth=1 https://github.com/Betterment/ruby_spec_helpers.git && rm -rf ruby_spec_helpers/.git`
      end
      cd "vendor/gems/ruby_spec_helpers" do
        rm_r(Dir.glob('.*') - %w(. ..))
        rm_r Dir.glob('*.md')
        rm_r %w(
          Gemfile
          Gemfile.lock
          spec
        ), force: true
        `sed -E -i.sedbak '/license/d' ruby_spec_helpers.gemspec`
        rm_r Dir.glob('**/*.sedbak')
      end
    end
  end
end
