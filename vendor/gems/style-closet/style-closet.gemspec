# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'style_closet/version'

Gem::Specification.new do |spec|
  spec.name          = "style_closet"
  spec.version       = StyleCloset::VERSION
  spec.authors       = ["Sarah Whinnem", "Zane Ma"]
  spec.email         = ["zane@betterment.com"]
  spec.summary       = "Betterment Style Closet - Shared Styles, Images, JS"
  spec.description   = "This a versioned Ruby Gem for shared styles, images, JS that is used throughout Betterment."
  spec.homepage      = ""

  spec.files         = (`git ls-files -z`.split("\x0") - %w(.gitignore)).reject{|obj| obj.start_with?("docs")}
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]


  spec.add_dependency("bourbon", "4.2")
  spec.add_dependency("neat", "1.7.2")

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
