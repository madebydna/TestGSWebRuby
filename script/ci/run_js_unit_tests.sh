#! /usr/bin/env bash

export DISPLAY="${DISPLAY:=:99}"

file=/usr/local/bin/restart_xvfb.sh

if [[ -x "$file" ]]
then
  $file
else
  echo "$file not found. Skipping."
fi

RAILS_ENV=test bundle exec rake teaspoon FORMATTERS="junit>tmp/js_tests_results.xml"
