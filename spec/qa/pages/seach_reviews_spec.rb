require 'features/page_objects/search_reviews_page'

describe 'Search reviews page' do
  context 'searching for a school by name' do
    it "should navigate directly to suggested school"
    # Type in Grant Elementary
    # Select an option
    # Should navigate directly to profile page for schools
  end

  context "searching for a school using the school picker" do
    it "should narrow down school by state and city" 
    # Click the Don’t see your school link above search box
    # Select State: CA, City: Alameda School: Alameda High School
    # Should go to Alameda High School
  end
end