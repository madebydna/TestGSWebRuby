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

end