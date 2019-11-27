#! /usr/bin/env bash

export DISPLAY="${DISPLAY:=:99}"

RAILS_ENV=test bundle exec rake teaspoon FORMATTERS="junit>tmp/js_tests_results.xml"
