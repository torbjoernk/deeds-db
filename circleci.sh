#!/bin/sh

case ${CIRCLE_NODE_INDEX} in
  0) RAILS_ENV=test \
      bundle exec rspec -r rspec_junit_formatter --format RspecJunitFormatter -o ${CIRCLE_TEST_REPORTS}/rspec/junit.xml
      ;;
  1) RAILS_ENV=test \
     DRIVER=saucelabs \
      bundle exec rspec -r rspec_junit_formatter --format RspecJunitFormatter -o ${CIRCLE_TEST_REPORTS}/rspec/junit.xml
      ;;
esac
