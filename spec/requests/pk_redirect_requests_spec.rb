require 'spec_helper'

describe 'School profile pk subdomain behavior' do
  let(:school) { FactoryGirl.build(:school) }


  it 'sh' do
    school = FactoryGirl.build(:school, state: 'dc', city: 'washington', id: 1, name: 'name')
    School.stub(:find).and_return(school)
    get 'http://www.greatschools.org/district-of-columbia/washington/1-name/'
    expect(response).to redirect_to('http://www.greatschools.org/washington-dc/washington/1-Name/')
  end



  it 'should redirect non-pk urls from pk subdomain to default subdomain' do
    get 'http://pk.greatschools.org/california/alameda/1-Alameda-High-School/'
    expect(response).to redirect_to('http://www.greatschools.org/california/alameda/1-Alameda-High-School/')

    get 'http://pk.server.greatschools.org/california/alameda/1-Alameda-High-School/'
    expect(response).to redirect_to('http://server.greatschools.org/california/alameda/1-Alameda-High-School/')
  end

  it 'should allow pk school profiles to be hosted from www' do
    School.stub(:find).and_return(school)
    get 'http://www.greatschools.org/california/alameda/preschools/Alameda-High-School/1/'
    expect(response).to_not redirect_to('http://pk.greatschools.org/california/alameda/preschools/Alameda-High-School/1/')
  end

end