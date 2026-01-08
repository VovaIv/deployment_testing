# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'

# Configure Capybara
Capybara.register_driver :remote_chrome do |app|
  url = ENV.fetch("SELENIUM_REMOTE_URL", "http://localhost:4444/wd/hub")
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    "goog:chromeOptions" => {
      args: %w[headless=new no-sandbox disable-dev-shm-usage window-size=1400,1400]
    }
  )
  Capybara::Selenium::Driver.new(app, browser: :remote, url: url, capabilities: capabilities)
end

Capybara.javascript_driver = :remote_chrome
Capybara.default_driver = :rack_test
Capybara.default_max_wait_time = 5

# Add additional requires below this line. Rails is not loaded until this point!

# Checks for pending migrations and applies them before tests are run.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_paths = [Rails.root.join('spec/fixtures')]
  config.use_transactional_fixtures = true
  
  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
end