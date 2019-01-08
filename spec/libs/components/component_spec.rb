# frozen_string_literal: true

require 'spec_helper'

describe Components::Component do
  describe '#text_value' do
    subject { Components::Component.new.text_value(value) }

    {
        '15.3' => '15',
        '18.9' => '19',
        '99.5' => '100',
        '49.49' => '49',
        '18' => '18',
        '30' => '30',
        '0.89' => '1',
        '0.50' => '1',
        '0.49' => '<1',
        '27.90' => '28',
        '75.0' => '75',
        '83.409' => '83',
        '0.00' => '<1',
        '-5' => '-5',
        '6th percentile' => '6th percentile',
        'seventy-nine' => 'seventy-nine',
        '5th' => '5th',
        ' 15  ' => '15',
        ' 1.0 ' => '1',
        ' 0.490 ' => '<1',
        15.3 => '15',
        18.9 => '19',
        99.5 => '100',
        49.49 => '49',
        18 => '18',
        30 => '30',
        0.89 => '1',
        0.50 => '1',
        0.49 => '<1',
        27.90 => '28',
        75.0 => '75',
        83.409 => '83',
        0.00 => '<1',
        -5 => '-5'

    }.each do |input, expected_output|
      context "With a value \"#{input}\"" do
        let (:value) { input }
        it { is_expected.to eq(expected_output) }
      end
    end

    describe '#float_value' do
      context "without precision" do
        subject { Components::Component.new(precision: nil).float_value(value) }
        {
          '15.3' => 15.3,
        }.each do |input, expected_output|
          context "With a value \"#{input}\"" do
            let (:value) { input }
            it { is_expected.to eq(expected_output) }
          end
        end
      end
    end
  end
end