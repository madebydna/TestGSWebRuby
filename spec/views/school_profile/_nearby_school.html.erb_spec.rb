require 'spec_helper'

describe 'school_profile/_nearby_school' do

  before do
    view.extend(UrlHelper)
    mocked_school = {"id" => 213, "name" => "Bret Harte Middle School", "city" => "Oakland", "state" => "CA", "type" => "public", "level" => "6-8", "review_score" => 4}
    render partial: "school_profile/nearby_school", locals: {school: mocked_school}
  end

  it 'renders the School name' do
    expect(rendered).to have_content('Bret Harte Middle School')
  end

  it 'renders one link with school name' do
    expect(rendered).to have_css('a', :count => 1, :text => 'Bret Harte Middle School')
  end

end
