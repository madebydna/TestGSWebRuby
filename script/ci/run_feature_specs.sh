#!/bin/bash

export DISPLAY="${DISPLAY:=:99}"

RAILS_ENV=test coverage=false bundle exec rspec \
--tag ~remote \
--tag ~brittle \
--no-color \
--failure-exit-code 1 \
--deprecation-out ./tmp/rspec_deprecation_warnings.txt \
--require ./spec/support/failures_html_formatter.rb \
--format RSpec::Core::Formatters::FailuresHtmlFormatter \
--out ./tmp/feature_spec_failures_html_report.html \
--format RspecJunitFormatter \
"$@"
