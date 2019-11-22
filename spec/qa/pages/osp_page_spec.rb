require 'features/page_objects/osp_page'

describe 'OSP page' do
  subject { OspPage.new }

  describe 'Basic Information' do
    before do
      subject.load(query: { page: 1, schoolId: 414, state: 'ca' })
    end
    # tests for presence and interactiveness of form fields
    it 'saves form when clicking on Save edits'
    it 'saves form when going to another page'
  end

  describe 'Academics' do
    before do
      subject.load(query: { page: 2, schoolId: 414, state: 'ca' })
    end
    # tests for presence and interactiveness of form fields
    it 'saves form when clicking on Save edits'
    it 'saves form when going to another page'
  end

  describe 'Extracurriculars & Culture' do
    before do
      subject.load(query: { page: 3, schoolId: 414, state: 'ca' })
    end
    # tests for presence and interactiveness of form fields
    it 'saves form when clicking on Save edits'
    it 'saves form when going to another page'
  end

end