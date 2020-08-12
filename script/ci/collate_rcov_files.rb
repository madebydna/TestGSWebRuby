#! /usr/bin/env ruby

require 'simplecov'
require 'simplecov-rcov'

SimpleCov.collate Dir["coverage/simplecov-resultset-*/coverage/.resultset.json"], 'rails' do
  formatter SimpleCov::Formatter::RcovFormatter
end