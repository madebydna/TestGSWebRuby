#!/usr/bin/ruby
# given list of strings on STDIN, will strip extra whitespace and then convert to a YML key/value, such as:
# foo  becomes  foo: foo
# and
# 123  becomes  '123': 123
#
# Example use (mysqlditto is a custom alias that just connects to mysql on the ditto server with the right credentials)
# echo "select distinct response_label from localized_profiles.response_values order by
# response_label asc" | mysqlditto | tail -n +2 | script/strings_to_yml_key_val.rb > config/locales/models/response_value.en.yml

require 'yaml'
array = STDIN.to_a.sort.uniq

hash = {}
array.each do |text|
  text = text.force_encoding('windows-1252').encode('utf-8') rescue text
  text.strip!
  next if text.to_i.to_s == text ||
    text == 'false' ||
    text == 'true' ||
    text.empty? ||
    text.match(/\.jpg$/) ||
    text.match(/\.png$/) ||
    text.match(/\.gs$/) ||
    text.match(/^https?:/) ||
    text.match(/^([^a-zA-Z])+$/) ||
    text.match(/^schools\/\?/) ||
    text.match(/\#\d+$/) ||
    text.match(/^\/[a-z\/-]+$/)

  key = text.gsub('.', '')
  key.strip!
  hash[key] = text
end

puts YAML.dump('en' => hash)
