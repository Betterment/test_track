namespace :test_track do
  task :vendor_deps do
    FileUtils.module_eval do
      cd "vendor/gems" do
        rm_r Dir.glob('*')
        `git clone --depth=1 git@github.com:Betterment/style-closet.git && rm -rf style-closet/.git`
        `git clone --depth=1 git@github.com:Betterment/ruby_spec_helpers.git && rm -rf ruby_spec_helpers/.git`
      end
      cd "vendor/gems/style-closet" do
        rm_r(Dir.glob('.*') - %w(. ..))
        rm_r Dir.glob('*.md')
        rm_r %w(
          Dockerfile
          docker-compose.yml
          docker-compose-dev.yml
          docker-sync.yml
          Gemfile
          Gemfile.lock
          _config.yml
          LICENSE.txt
          Gruntfile.js
          buildGem.sh
          docs
          script
          package.json
          Rakefile
          bin
          spec
          app/assets/fonts
          app/assets/images
          app/assets/javascripts
        ), force: true
        cd "app/assets/stylesheets/style-closet" do
          rm_r %w(
            typography/_font-museo.scss
            typography/_font-pictograms.scss
            _accordions.scss
            _agreements.scss
            _dashboard-header.scss
            _modals.scss
            _progress-bar.scss
            _success.scss
            _takeovers.scss
            _to-deprecate.scss
          ), force: true
        end
        `sed -E -i.sedbak '/font-(museo|pictograms)/d' app/assets/stylesheets/style-closet/_typography.scss`
        removals = %w(accordions agreements dashboard-header modals progress-bar success takeovers to-deprecate)
        `sed -E -i.sedbak '/#{removals.join('|')}/d' app/assets/stylesheets/_style-closet.scss`
        `sed -E -i.sedbak '/license/d' style-closet.gemspec`
        rm_r Dir.glob('**/*.sedbak')
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
