require 'capybara/rails'
require 'capybara/rspec'
require 'selenium-webdriver'
require 'fileutils'

driver = ENV.fetch("DRIVER", "webkit").to_sym

case driver
  when :webkit
    Capybara.register_driver :webkit do |app|
      browser = Capybara::Webkit::Browser.new(Capybara::Webkit::Connection.new).tap do |browser|
        browser.ignore_ssl_errors
      end
      Capybara::Webkit::Driver.new(app, browser: browser)
    end
  when :poltergeist
    require 'capybara/poltergeist'
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, js_errors: false, phantomjs_logger: Logger.new('/dev/null'), timeout: 60)
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
  config.default_driver = driver
  config.javascript_driver = driver

  capybara_wait_time = ENV.fetch('CAPYBARA_WAIT_TIME', 10).to_i
  if config.respond_to? :default_max_wait_time=
    config.default_max_wait_time = capybara_wait_time
  else
    config.default_wait_time = capybara_wait_time
  end
end

module CapybaraScreenshotHelpers
  def self.screenshot_directory
    @screenshot_directory ||= Rails.root.join("spec", "error_screenshots", ENV.fetch("SCREENSHOT_DIR", Time.now.to_i.to_s))
  end

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

  def screenshot_on_error(example)
    if example.exception.present?
      filename = "#{example.metadata[:full_description]}.png".gsub(/\ /, "_")
      screenshot "#{CapybaraScreenshotHelpers.screenshot_directory}/#{filename}"
    end
  end
end

RSpec.configure do |config|
  config.include CapybaraScreenshotHelpers, type: :feature

  config.after(:each, type: :feature) do |example|
    screenshot_on_error example
    Capybara.reset_sessions!
  end

  config.after(:suite) do
    error_screenshot_directory = CapybaraScreenshotHelpers.screenshot_directory
    puts "\nError screenshots saved to: #{error_screenshot_directory}" if File.directory?("#{error_screenshot_directory}")

    # remove any paperclip attachments
    FileUtils.rm_rf(Dir["#{Rails.root}/spec/test_files/"])
  end
end
