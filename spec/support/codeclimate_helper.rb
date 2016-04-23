if ENV['CI'] == 'true' and ENV.has_key? 'WITH_CODECLIMATE'
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end
