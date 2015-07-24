#!/usr/bin/ruby
# given list of strings on STDIN, will strip extra whitespace and then convert to a YML key/value, such as:
# foo  becomes  foo: foo
# and
# 123  becomes  '123': 123
#
# First optional parameter is number of spaces to indent by
#
# Example use (mysqlditto is a custom alias that just connects to mysql on the ditto server with the right credentials)
# echo "select distinct response_label from localized_profiles.response_values order by
# response_label asc" | mysqlditto | tail -n +2 | script/strings_to_yml_key_val.rb 4 >> config/locales/models/response_value.en.yml

indent = ARGV[0].to_i
require 'yaml'
STDIN.to_a.each do |text|
  # note from samson
  # I tried to use YAML.dump / obj.to_yaml to generate yaml instead of doing this
  # however, those yaml generating methods don't property escape periods
  # i18n-tasks library does, but I couldn't isolate the code that was doing that
  output_string = ''
  output_string << ' ' * indent
  s = '\'' + text.gsub('.', '').gsub('"', '\"').gsub(/\n/, '').gsub('\'','\'\'') + '\''
  output_string << s << ': ' << s
  puts output_string
end
