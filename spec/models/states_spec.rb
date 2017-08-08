require 'spec_helper'

describe 'states' do

  it 'should handle multi word states' do
    expect(States.abbreviation 'washington dc').to eq('dc')
    expect(States.abbreviation 'north carolina').to eq('nc')
  end

  it 'should correctly handle washington dc' do
    expect(States.state_name 'dc').to eq('washington dc')
    expect(States.abbreviation 'district of columbia').to eq('dc')
    expect(States.abbreviation 'washington dc').to eq('dc')
  end

  it 'should be case in-sensitive and return downcase' do
    expect(States.state_name 'CA').to eq('california')
    expect(States.abbreviation 'CALIFORNIA').to eq('ca')
  end

  describe '#any_state_name_regex' do
    it 'should match a one-word state' do
      expect(States.any_state_name_regex.match 'colorado').to_not be_nil
    end

    it 'should match washington dc' do
      expect(States.any_state_name_regex.match 'washington-dc').to_not be_nil
      expect(States.any_state_name_regex.match 'district-of-columbia').to_not be_nil
    end

    it 'should match multi-word names' do
      expect(States.any_state_name_regex.match 'south-carolina').to_not be_nil
    end

    it 'should not match junk' do
      expect(States.any_state_name_regex.match '-').to be_nil
      expect(States.any_state_name_regex.match ' ').to be_nil
    end

    it 'should not match a partial state name' do
      expect(States.any_state_name_regex.match 'carolina').to be_nil
    end
  end

  describe '#any_state_abbreviation_regex' do
    it 'should match CA and be case-insensitive' do
      expect(States.any_state_abbreviation_regex.match 'CA').to_not be_nil
      expect(States.any_state_abbreviation_regex.match 'ca').to_not be_nil
    end

    it 'should match washington dc' do
      expect(States.any_state_abbreviation_regex.match 'dc').to_not be_nil
    end

    it 'should not match junk' do
      expect(States.any_state_abbreviation_regex.match 'foo').to be_nil
      expect(States.any_state_abbreviation_regex.match '-').to be_nil
      expect(States.any_state_abbreviation_regex.match ' ').to be_nil
      expect(States.any_state_abbreviation_regex.match 'zz').to be_nil
    end

    it 'should not match a full state name' do
      expect(States.any_state_abbreviation_regex.match 'california').to be_nil
    end
  end

  describe '.abbreviation' do
    context 'normal input' do
      it 'returns the abbreviation' do
        expect(States.abbreviation('michigan')).to eq('mi')
      end
    end

    context 'abbreviation input' do
      it 'returns the input abbreviation' do
        expect(States.abbreviation('mi')).to eq('mi')
      end
    end
  end

  describe '.abbr_to_label' do
    context 'normal input' do
      it 'returns the capitalized state' do
        expect(States.abbr_to_label('mi')).to eq('Michigan')
      end
    end

    context 'gibberish input' do
      it 'returns nil' do
        expect(States.abbr_to_label('df')).to eq(nil)
      end
    end
    context 'dc as input' do
      it 'returns Washington DC' do
        expect(States.abbr_to_label('dc')).to eq('Washington DC')
      end
    end
  end

  describe '.state_path' do
    {
        ca: 'california',
        dc: 'washington-dc',
        ma: 'massachusetts',
        nj: 'new-jersey',
        sd: 'south-dakota',
        xx: nil
    }.each do |abbreviation, expected_path|
      context abbreviation do
        subject { States.state_path(abbreviation.to_s) }
        it { should eq(expected_path) }
      end
    end

    context 'handles nil' do
      subject { States.state_path(nil) }
      it { should be_nil }
    end
  end
end
