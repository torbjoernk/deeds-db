require 'selenium/webdriver'

module SauceDriver
  class << self
    def sauce_endpoint
      "http://#{ENV['SAUCE_USERNAME']}:#{ENV['SAUCE_ACCESS_KEY']}@ondemand.saucelabs.com:80/wd/hub"
    end

    def caps(name)
      {
          platform: 'Linux',
          browserName: 'Chrome',
          version: '31',
          name: name
      }
    end

    def new_driver(name)
      Selenium::WebDriver.for :remote, :url => sauce_endpoint, :desired_capabilities => caps(name)
    end
  end
end
