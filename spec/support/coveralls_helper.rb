if ENV['CI'] == 'true' and ENV.has_key? 'WITH_COVERALLS'
  require 'coveralls'
  Coveralls.wear!('rails')
end
