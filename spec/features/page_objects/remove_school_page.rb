class RemoveSchoolPage < SitePrism::Page
  set_url '/remove_school/'

  section :form, 'form#new_remove_school_submission' do
    # list form elements here
    element :gs_web_link, 'input#remove_school_submission_gs_url'
  end
  
end