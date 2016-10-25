require 'style_closet/version'
require 'fileutils'
require 'thor'

module StyleCloset
  class Generator < Thor
    map ["-v", "--version"] => :version

    desc "install", "Install StyleCloset into your project"
    method_options :path => :string, :stylesheet_path => :string, :font_path => :string, :image_path => :string, :javascript_path => :string, :force => :boolean
    def install
      if style_closet_files_already_exist? && !options[:force]
        puts "StyleCloset files already installed, doing nothing."
      else
        install_files
        puts "StyleCloset files installed."
      end
    end

    desc "update", "Update StyleCloset"
    method_options :path => :string, :stylesheet_path => :string, :font_path => :string, :image_path => :string, :javascript_path => :string
    def update
      if style_closet_files_already_exist?
        remove_style_closet_directories
        install_files
        puts "StyleCloset files updated."
      else
        puts "No existing style_closet installation. Doing nothing."
      end
    end

    desc "version", "Show StyleCloset version"
    def version
      say "StyleCloset #{StyleCloset::VERSION}"
    end

    private

    def style_closet_files_already_exist?
      stylesheet_path.exist?
    end

    def base_path
      options[:stylesheet_path] || options[:path]
    end

    def stylesheet_path
      @stylesheet_path ||= if base_path
          Pathname.new(File.join(base_path, "style_closet"))
        else
          Pathname.new("style_closet")
        end
    end

    def font_path
      @font_path ||= if options[:font_path]
          Pathname.new(options[:font_path])
        else
          Pathname.new(File.join(stylesheet_path, "fonts"))
        end
    end

    def image_path
      @image_path ||= if options[:image_path]
          Pathname.new(options[:image_path])
        else
          Pathname.new(File.join(stylesheet_path, "images"))
        end
    end

    def javascript_path
      @javascript_path ||= if options[:javascript_path]
          Pathname.new(options[:javascript_path])
        else
          Pathname.new(File.join(stylesheet_path, "javascripts"))
        end
    end

    def install_files
      if style_closet_files_already_exist?
        remove_style_closet_directories
      end

      make_install_directories
      copy_in_stylesheets
      copy_in_fonts

      if options[:image_path]
        copy_in_images
      end

      if options[:javascript_path]
        copy_in_javascripts
      end
    end

    def remove_style_closet_directories
      puts "Removing old files"
      FileUtils.rm_rf(stylesheet_path)
      FileUtils.rm_rf(font_path)
      FileUtils.rm_rf(image_path + '/style_closet')
      FileUtils.rm_rf(javascript_path + '/style_closet')
    end

    def make_install_directories
      FileUtils.mkdir_p(stylesheet_path)
      FileUtils.mkdir_p(font_path)

      if options[:image_path]
        FileUtils.mkdir_p(image_path)
      end

      if options[:javascript_path]
        FileUtils.mkdir_p(javascript_path)
      end
    end

    def copy_in_stylesheets
      FileUtils.cp_r(all_stylesheets, stylesheet_path)
    end

    def copy_in_fonts
      FileUtils.cp_r(all_fonts, font_path)
    end

    def copy_in_images
      FileUtils.cp_r(all_images, image_path)
    end

    def copy_in_javascripts
      FileUtils.cp_r(all_javascripts, javascript_path)
    end

    def all_stylesheets
      Dir["#{stylesheets_directory}/*"]
    end

    def all_fonts
      Dir["#{fonts_directory}/*"]
    end

    def all_images
      Dir["#{image_directory}/*"]
    end

    def all_javascripts
      Dir["#{javascripts_directory}/*"]
    end

    def stylesheets_directory
      File.join(top_level_directory, "app", "assets", "stylesheets")
    end

    def fonts_directory
      File.join(top_level_directory, "app", "assets", "fonts")
    end

    def image_directory
      File.join(top_level_directory, "app", "assets", "images")
    end

    def javascripts_directory
      File.join(top_level_directory, "app", "assets", "javascripts")
    end

    def top_level_directory
      File.dirname(File.dirname(File.dirname(__FILE__)))
    end
  end
end
