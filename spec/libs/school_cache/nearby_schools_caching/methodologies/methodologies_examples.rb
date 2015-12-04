require 'spec_helper'

shared_examples_for 'methodologies that use lat lons' do

  let(:school_without_lat) do
    FactoryGirl.create(:alameda_high_school,
                       id: 1,
                       state: 'CA',
                       lon: 144,
                       level_code: 'h'
                      )
  end

  let(:school_without_lon) do
    FactoryGirl.create(:alameda_high_school,
                       id: 1,
                       state: 'CA',
                       lat: 32,
                       level_code: 'h'
                      )
  end


  it 'should return [] if the school does not have a lat' do
    schools = subject.schools(school_without_lat, opts)
    expect(schools).to eq([])
  end

  it 'should not throw a active record error if the school does not have a lat' do
    expect{subject.schools(school_without_lat, opts)}.not_to raise_error
  end

  it 'should not throw a active record error if the school does not have a lon' do
    expect{subject.schools(school_without_lon, opts)}.not_to raise_error
  end

  it 'should return [] if the school does not have a lon' do
    schools = subject.schools(school_without_lon, opts)
    expect(schools).to eq([])
  end
end
