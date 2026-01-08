require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'

# Only register a JS driver if you plan to use JS tests in the future
Capybara.register_driver :remote_chrome do |app|
  url = ENV.fetch("SELENIUM_REMOTE_URL", "http://chrome:4444/wd/hub")
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    "goog:chromeOptions" => {
      args: %w[headless=new no-sandbox disable-dev-shm-usage window-size=1400,1400]
    }
  )
  Capybara::Selenium::Driver.new(app, browser: :remote, url: url, capabilities: capabilities)
end

# Default driver for non-JS tests
Capybara.default_driver = :rack_test
Capybara.javascript_driver = :remote_chrome

Capybara.default_max_wait_time = 5

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_paths = [Rails.root.join('spec/fixtures')]
  config.use_transactional_fixtures = true
  config.filter_rails_from_backtrace!
end
