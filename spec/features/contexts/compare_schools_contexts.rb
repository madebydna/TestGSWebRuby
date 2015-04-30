require 'spec_helper'

shared_context 'Visit Compare Page' do
  before do
    visit compare_schools_path(school_ids: school.id, state: school.state)
  end
end

shared_context 'the compare page value of' do |text=nil|
  subject do
    cp_text =  text || compare_page_text
    [*cp_text].flatten.map do |t|
      attribute = find('td', text: t)
      attribute.find(:xpath, "following-sibling::*[1]")
      #sadly no capybara/site prism way to cleanly grab sibling element
      #had to resort to xpath
    end
  end
end
