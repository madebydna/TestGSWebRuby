require 'features/page_objects/remove_school_page'

describe 'Remove school page', remote: true do

  subject { RemoveSchoolPage.new }

  before { subject.load }

  it 'requires a GS web link'
  it 'validates that theGS web link includes www.greatschools.org/' 
  it 'requires a role'
  it 'requires an email address'
  it 'has Recapcha'
  it 'submits form successfully'

end