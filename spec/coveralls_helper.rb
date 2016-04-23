if ENV['CI'] == 'true'
  require 'coveralls'
  Coveralls.wear!('rails')
end
