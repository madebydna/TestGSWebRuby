require 'spec_helper'

describe 'user searches for school on home page' do
  after do
   clean_dbs(:gs_schooldb)
   clean_models(:ca, School)
  end
  scenario 'finds the desired school from autocomplete', js: true do
    FactoryGirl.create(:alameda_high_school)
    stub_solr_suggest_response

    visit home_path
    fill_in_autocomplete('input[name="locationSearchString"]', 'Alameda high school')
    click_on_autocomplete_result

    expect(current_path).to include('Alameda')
  end

  def fill_in_autocomplete(selector, value)
    page.execute_script "$('#{selector}').eq(0).val('#{value}').trigger('input');"
  end

  def click_on_autocomplete_result
    find(".twitter-typeahead").find("a").click
  end

  def stub_solr_suggest_response
    school_response = FactoryGirl.build(:solr_response_object_alameda_high_school)
    search_regex =  /.*\/main\/select\/\?fq=%2Bdocument_type:school&q=%2Bschool_name_untokenized:alameda%5C%20high%5C%20school.*/
    stub_request(:get, search_regex).
      to_return(:status => 200, :body => "#{school_response}", :headers => {})
  end
end

