require 'features/page_objects/add_school_page'

describe 'Add school page', remote: true do

  subject { AddSchoolPage.new }

  before { subject.load }

  it 'removes NCES field when Pre-K is selected'
  it 'does not validate NCES fields for Pre-K schools'
  it 'validates 8-character NCES code for private schools'
  it 'validates 12-character NCES code for public schools'
  it 'validates 5-digit zip code'
  it 'enforces Recapcha'
  it 'removes mailing address fields if the same as physical address'
  it 'has mailing address fields if not the same as physical address'
  
  it 'submits new school successfully'


end