require 'spec_helper'

describe 'School Profile redirect on query string tab param' do
  it 'should redirect reviews' do
    get 'http://www.greatschools.org/michigan/detroit/1073-Cass-Technical-High-School/?tab=reviews&test3=999'
    expect(response).to redirect_to('http://www.greatschools.org/michigan/detroit/1073-Cass-Technical-High-School/reviews/?test3=999')
  end

  it 'should redirect test scores to quality' do
    get 'http://www.greatschools.org/michigan/detroit/1073-Cass-Technical-High-School/?tab=test-scores'
    expect(response).to redirect_to('http://www.greatschools.org/michigan/detroit/1073-Cass-Technical-High-School/quality/')
  end
  it 'should redirect programs culture to details' do
    get 'http://www.greatschools.org/michigan/detroit/1073-Cass-Technical-High-School/?test55=999000&tab=programs-culture'
    expect(response).to redirect_to('http://www.greatschools.org/michigan/detroit/1073-Cass-Technical-High-School/details/?test55=999000')
  end
end