require 'capybara/rails'
require 'capybara/rspec'
require 'selenium-webdriver'
require 'fileutils'

ENV["SCREENSHOT_DIR"] ||= Time.now.to_i.to_s
capybara_wait_time = (ENV['CAPYBARA_WAIT_TIME'] || 10).to_i
driver = (ENV["DRIVER"] || "webkit").to_sym
webkit_debug = (!ENV["WEBKIT_DEBUG"].nil? && ENV["WEBKIT_DEBUG"] == "true") ? true : false

case driver
  when :webkit
    Capybara.register_driver :webkit do |app|
      browser = Capybara::Webkit::Browser.new(Capybara::Webkit::Connection.new).tap do |browser|
        browser.ignore_ssl_errors
      end
      driver = Capybara::Webkit::Driver.new(app, browser: browser)
      driver.enable_logging if webkit_debug
      driver
    end
  when :poltergeist
    require 'capybara/poltergeist'
    Capybara.register_driver :poltergeist do |app|
      driver = Capybara::Poltergeist::Driver.new(app, js_errors: false, phantomjs_logger: Logger.new('/dev/null'))
      driver
    end
  else
    Capybara.register_driver driver do |app|
      Capybara::Selenium::Driver.new(app, browser: driver)
    end
end

Capybara.configure do |config|
  config.match = :one
  config.exact_options = true
  config.ignore_hidden_elements = true
  config.visible_text_only = true
  config.default_wait_time = capybara_wait_time
  config.default_driver = driver
  config.javascript_driver = driver
end

module CapybaraScreenshotHelpers
  def screenshot(filename)
    options = {}
    case Capybara.current_driver
      when :webkit
        options[:width] = page.driver.evaluate_script("document.documentElement.clientWidth")
        options[:height] = page.driver.evaluate_script("document.documentElement.clientHeight")
      when :poltergeist
        options[:full] = true
    end
    page.save_screenshot "#{filename}", options
  end

  private

  def screenshot_name(example)
    "#{example.metadata[:full_description]}.png".gsub(/\ /, "_")
  end

  def screenshot_on_error(example)
    if !example.exception.nil?
      dirname = "spec/error_screenshots/#{ENV["SCREENSHOT_DIR"]}"
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
      screenshot "#{dirname}/#{screenshot_name(example)}"
    end
  end

  def print_console_messages
    if page.driver.respond_to?(:errors_messages)
      p page.driver.error_messages unless page.driver.error_messages.empty?
      # uncomment for ALL console messages, not just console.error
      # p page.driver.console_messages unless page.driver.console_messages.empty?
    end
  end
end

RSpec.configure do |config|
  config.include CapybaraScreenshotHelpers, type: :feature

  config.after(:each, type: :feature) do |example|
    if example.exception && page.driver.respond_to?(:console_messages)
      puts page.driver.console_messages.find_all { |message| !message.to_s.include? 'mixpanel' }
      puts page.driver.error_messages.find_all { |message| !message.to_s.include? 'mixpanel' }
    end
    screenshot_on_error example
    Capybara.reset_sessions!
  end

  config.after(:suite) do
    error_screenshot_directory = "spec/error_screenshots/#{ENV["SCREENSHOT_DIR"]}"
    puts "\nError screenshots saved to: #{error_screenshot_directory}" if File.directory?("#{error_screenshot_directory}")

    # remove any paperclip attachments
    FileUtils.rm_rf(Dir["#{Rails.root}/spec/test_files/"])
  end
end
