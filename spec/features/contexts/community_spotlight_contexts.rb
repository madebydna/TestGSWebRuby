shared_context 'visit community spotlight with collection, schools, and data' do
  let(:school_ids) { [403, 405, 437, 547, 5523, 5580, 11902, 14052, 14144, 16974] }
  let(:school_data_struct) { Struct.new(:school_id, :state) }
  let(:solr_response) {
    {
      school_data: school_ids.map { |id| school_data_struct.new(id, 'ca') },
      more_results: true
    }
  }
  let(:collection_config) {
    {
      "url_name" => "sf-bay-area",
      "scorecard_fields" => [
        { "data_type" => "school_info", "partial" => "school_info" },
        { "data_type" => "a_through_g", "partial" => "percent_value", "year" => 2014 },
        { "data_type" => "graduation_rate", "partial" => "percent_value", "year" => 2013 }
      ],
      scorecard_params: {
        gradeLevel: 'h',
        schoolType: ['public', 'charter'],
        sortBy: 'a_through_g',
        sortBreakdown: 'hispanic',
        sortAscOrDesc: 'desc',
        offset: 0,
      }
    }.to_json
  }
  let!(:collection) { FactoryGirl.create(:collection, config: collection_config) }
  let(:community_spotlight_page) { CommunitySpotlightPage.new }

  before do
    school_ids.each do |id|
      FactoryGirl.create(:school, id: id, state: 'ca')
      FactoryGirl.create(:school_characteristic_responses, school_id: id, state: 'ca')
    end
    allow_any_instance_of(CommunityScorecardData).to receive(:solr_response).and_return(solr_response)
    visit community_spotlight_path(collection_id: collection.id, collection_name: collection.url_name)
  end

  after do
    clean_models :ca, School
    clean_models :gs_schooldb, SchoolCache, Collection, HubCityMapping
  end
end

shared_context 'click .js-drawTable element with' do |attribute, value|
  before do
    triggers = community_spotlight_page.draw_table_triggers
    this_trigger = triggers.select { |t| t[attribute] == value }.first
    this_trigger.click
    wait_for_scorecard_to_draw
  end
end

def wait_for_scorecard_to_draw
  loop do
    if page.evaluate_script('GS.CommunityScorecards.Page.shouldDraw')
      break
    end
  end
end
