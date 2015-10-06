shared_context 'setup community spotlight' do |query_params|
  let(:school_ids) { [403, 405, 437, 547, 5523, 5580, 11902, 14052, 14144, 16974] }
  let(:school_data_struct) { Struct.new(:id, :state) }
  let(:solr_response) {
    # TODO create a hash with a key: value for each datatype-breakdown-grade
    {
      school_data: school_ids.map { |id| school_data_struct.new(id, 'ca') },
      more_results: true
    }
  }
  let(:config) { collection_config.merge( url_name: 'url-name' ).to_json }
  let!(:collection) { FactoryGirl.create(:collection, config: config) }
  let(:community_spotlight_page) { CommunitySpotlightPage.new }

  before do
    school_ids.each do |id|
      FactoryGirl.create(:school, id: id, state: 'ca')
      FactoryGirl.create(:school_characteristic_responses, school_id: id, state: 'ca')
    end
    allow_any_instance_of(CommunityScorecardData).to receive(:solr_response).and_return(solr_response)
    query_params ||= {}
    path_params = query_params.merge(collection_id: collection.id, collection_name: collection.url_name)
    visit community_spotlight_path(path_params)
  end

  after do
    clean_models :ca, School
    clean_models :gs_schooldb, SchoolCache, Collection
  end
end

shared_context 'click .js-drawTable element with' do |attribute, value|
  before do
    triggers = community_spotlight_page.draw_table_triggers
    target_trigger = triggers.select { |t| t[attribute] == value }.first
    parent = target_trigger.parent
    if parent.is_a?(Capybara::Node::Element) && parent[:class].include?('bootstrap-select')
      target_trigger.parent.click
    end
    target_trigger.click
    wait_for_scorecard_to_draw
  end
end

def wait_for_scorecard_to_draw
  begin
    timeout(5) do # 5 second timeout
      loop do
        if page.evaluate_script('GS.CommunityScorecards.Page.shouldDraw')
          break
        end
      end
    end
  rescue Timeout::Error
    raise "Too long passed waiting for the scorecard to finish drawing."
  end
end
