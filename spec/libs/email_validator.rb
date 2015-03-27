require 'spec_helper'

describe EmailValidator do

  # TODO: Might benefit from implementation using mail library and Mail::Address to parse email
  # to check for format validity
  describe '#format_valid?' do
    valid = [
      'foo..bar@example.com',
      'example@93478937.com',
      'example@some-domain.com',
      'example@example.com',
      'foo.bar@example.com',
      'foo.bar+baz@example.com',
      '" "@example.com'
    ]

    invalid = [
      'foobarbaz',
      'foobar@example',
      'foobar@example..com',
      'foo@bar@example.com'
    ]

    should_be_invalid = [
      '[[((@example.com',
      'example@a.com'
    ]

    valid.each do |email|
      it "'#{email}' should be valid" do
        expect(EmailValidator.new(email).format_valid?).to be_truthy
      end
    end

    invalid.each do |email|
      it "'#{email}' should be invalid" do
        expect(EmailValidator.new(email).format_valid?).to be_falsey
      end
    end

    should_be_invalid.each do |email|
      it "'#{email}' should be invalid" do
        pending ('Make format_valid? method better')
        expect(EmailValidator.new(email).format_valid?).to be_falsey
      end
    end
  end
end
