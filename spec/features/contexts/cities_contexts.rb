require 'spec_helper'

#creates cities in us geo. takes single or array of hashes of city attirbutes for factory girl
#ex. [{state: 'mn', name: 'st. paul'}, {state: 'dc', name: 'washinton', lat: 1234}]
shared_context 'Given the following city(s) are in the db' do |cities|
  before do
    [*cities].each do |city|
      create(:city, city)
    end
  end

  after { clean_dbs :us_geo }
end
