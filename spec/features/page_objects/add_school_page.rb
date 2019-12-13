class AddSchoolPage < SitePrism::Page
  set_url '/add_school/'

  section :form, 'form#new_new_school_submission' do
    # list form elements here
    element :nces_code, 'input#new_school_submission_nces_code'
  end
  
end