require 'spec_helper'

describe 'School Profile redirect on query string tab param' do
  before do
    FactoryGirl.create(:school_with_new_profile,
                      state: 'ca',
                      city: 'alameda',
                      id: 1,
                      name: 'Alameda High School',
                      level_code: 'e,m,h',
                      new_profile_school: 5
    )
  end
  after do
    clean_dbs :ca
  end
  it 'should redirect reviews' do
    get 'http://www.greatschools.org/california/alameda/1-Alameda-High-School/?tab=reviews&test3=999'
    expect(response.code).to eq('200')
  end

  it 'should redirect test scores to quality' do
    get 'http://www.greatschools.org/california/alameda/1-Alameda-High-School/?tab=test-scores&test3=999'
    expect(response.code).to eq('200')
  end
  it 'should redirect programs culture to details' do
    get 'http://www.greatschools.org/california/alameda/1-Alameda-High-School/?tab=programs-culture&test3=999'
    expect(response.code).to eq('200')
  end
end