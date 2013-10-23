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

end