require 'features/page_objects/osp_register_page'

describe 'OSP Register page' do
  subject { OspRegisterPage.new }

  before do
    subject.load(query: {schoolId: 312, state: 'ca'})
  end

  it 'should contain prompt to claim school profile' do
    expect(subject.osp_header.main_title).to have_text("Claim your school profile")
  end

  context 'as an unregistered user' do
    before do
      fill_out_form
    end

    it 'should submit form and display success message'
    # redirects to page with "Thanks for creating a school account!"
    it 'should send verification email with activation link'
    
    describe 'activating the school account' do
      before do
        # click on activation link
      end

      it 'should redirect to school form' # school/esp/form.page
      # further testing of this page, see school_form_page
    end
  end


  context 'as an authenticated user' do
    before do
      sign_in_as_testuser
      fill_out_form(new_user: false)
    end

    it 'should redirect to school form' 
  end


  def fill_out_form(new_user: true)
    if new_user
      subject.osp_form.email.set(random_email)
      subject.osp_form.password.set('secret123')
      subject.osp_form.password_confirmation.set('secret123')
    end
    # fill out the rest of the fields ...
    # special challenge: math problem capcha before submit
  end


end