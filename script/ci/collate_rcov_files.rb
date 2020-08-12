#! /usr/bin/env ruby

require 'simplecov'

SimpleCov.collate Dir["coverage/simplecov-resultset-*/.resultset.json"]