#!/bin/sh

case ${CIRCLE_NODE_INDEX} in
  0) echo 'headless RSpec with CodeClimate'
     RAILS_ENV=test WITH_CODECLIMATE=true \
       bundle exec rspec -r rspec_junit_formatter --format RspecJunitFormatter -o ${CIRCLE_TEST_REPORTS}/rspec/junit.xml
     ;;
  1) echo 'headless RSpec with Coveralls'
     RAILS_ENV=test WITH_COVERALLS=true \
       bundle exec rspec -r rspec_junit_formatter --format RspecJunitFormatter -o ${CIRCLE_TEST_REPORTS}/rspec/junit.xml
     ;;
  2) echo 'RSpec with SauceLabs and Coveralls'
     RAILS_ENV=test WITH_COVERALLS=true \
       DRIVER=saucelabs \
       bundle exec rspec -r rspec_junit_formatter --format RspecJunitFormatter -o ${CIRCLE_TEST_REPORTS}/rspec/junit.xml
     ;;
  *) echo 'unused'
     ;;
esac
