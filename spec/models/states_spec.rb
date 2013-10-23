require 'spec_helper'

describe 'states' do

  it 'should handle multi word states' do
    expect(States.abbreviation 'washington dc').to eq('dc')
    expect(States.abbreviation 'north carolina').to eq('nc')
  end

  it 'it should correctly handle washington dc' do
    expect(States.state_name 'dc').to eq('washington dc')
    expect(States.abbreviation 'district of columbia').to eq('dc')
    expect(States.abbreviation 'washington dc').to eq('dc')
  end

end