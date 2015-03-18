require 'spec_helper'

describe UrlUtils do
  describe '#contains_url?' do
    should_contain_url = [
      'google.com',
      'foo google.com bar',
      'google.com bar',
      'foo google.com',
      'www.google.com',
      'http://www.google.com',
      'https://www.google.com',
      '//www.google.com',
      'http://www.google.com/',
      'https://www.google.com/',
      '//www.google.com/',
      '//www.google.co/'
    ]
    should_not_contain_url = [
      # 'www.domain.a', # fails test
      'foo bar http www com baz'
    ]
    should_contain_url.each do |string|
      it "find a url within #{string}" do
        expect(UrlUtils.contains_url?(string)).to be_truthy
      end
    end
    should_not_contain_url.each do |string|
      it "not find a url within #{string}" do
        expect(UrlUtils.contains_url?(string)).to be_falsey
      end
    end
  end
end