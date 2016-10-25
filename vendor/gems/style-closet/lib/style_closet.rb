dir = File.dirname(__FILE__)
$:.unshift dir unless $:.include?(dir)

require 'style_closet/generator'

unless defined?(Sass)
  require 'sass'
end

module StyleCloset
  if defined?(Rails) && defined?(Rails::Engine)
    class Engine < ::Rails::Engine
      require 'style_closet/engine'
    end
  else
    style_closet_path = File.expand_path("../../app/assets/stylesheets", __FILE__)
    ENV["SASS_PATH"] = [ENV["SASS_PATH"], style_closet_path].compact.join(File::PATH_SEPARATOR)
  end
end
