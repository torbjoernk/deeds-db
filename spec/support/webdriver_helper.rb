
driver = ENV['DRIVER'].try(:to_sym)

if driver == :saucelabs
  require_relative 'sauce_driver'
  require 'sauce_whisk'

  RSpec.configure do |config|
    config.around(:example, :run_on_sauce => true) do |example|
      @driver = SauceDriver.new_driver example.full_description
      job_id = @driver.session_id
      begin
        example.run
      ensure
        SauceWhisk::Jobs.change_status job_id, example.exception.nil?
        @driver.quit
      end
    end
  end

  puts 'Using SauceLabs web driver for :run_on_sauce examples.'
end
