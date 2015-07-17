require 'spec_helper'

describe 'school_profile/_nearby_school_display' do

  context 'with ads not turned off' do

    before do
      mocked_school = {}
      stub_template  "layouts/_ad_layer.html.erb" => "ad is displayed"
      stub_template  "school_profile/_nearby_school.html.erb" => "this content"
      allow_any_instance_of(SchoolProfileDecorator).to receive(:school_zip_location_search_url).and_return("url")
      @show_ads = true
      render partial: "school_profile/nearby_school_display", locals: {title: "Nearby schools", schools: [mocked_school]}
    end

    it 'should show ads' do
      expect(rendered).to have_content("ad is displayed")
    end

    it 'renders the title' do
      expect(rendered).to have_content("Nearby schools")
    end

    it 'renders the nearby_school partial' do
      expect(rendered).to have_content("this content")
    end

  end

  context 'with ads turned off' do
    before do
      mocked_school = {}
      stub_template  "school_profile/_nearby_school.html.erb" => "this content"
      allow_any_instance_of(SchoolProfileDecorator).to receive(:school_zip_location_search_url).and_return("url")
      @show_ads = false
      render partial: "school_profile/nearby_school_display", locals: {title: "Nearby schools", schools: [mocked_school] }
    end

    it 'renders the title' do
      expect(rendered).to have_content("Nearby schools")
    end

    it 'renders the nearby_school partial' do
      expect(rendered).to have_content("this content")
    end

    it 'should not show ads' do
      expect(rendered).to_not have_css(".gs_ad_slot")
    end
  end


end
