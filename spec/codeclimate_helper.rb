if ENV['CI'] == 'true'
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end
