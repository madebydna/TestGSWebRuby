require 'features/selectors/community_spotlight_page'
require 'features/contexts/community_spotlight_contexts'
require 'features/examples/url_examples'
require 'features/examples/page_examples'

shared_examples 'community spotlight assertions' do |collection_config|
  SUBGROUP_SELECT_DESKTOP_SELECTOR = "[data-id='subgroup-select']"
  SUBGROUP_SELECT_MOBILE_SELECTOR  = "[data-id='subgroup-select-mobile']"
  DATA_TYPE_SELECT_MOBILE_SELECTOR = "[data-id='data-type-select-mobile']"
  QUERY_PARAM_KEYS = [:sortBy, :sortBreakdown, :sortAscOrDesc]

  let(:collection_config) { collection_config }
  scorecard_params = collection_config[:scorecard_params]

  context "with default params: #{scorecard_params}" do

    with_shared_context 'setup community spotlight' do
      include_examples 'basic spotlight assertions', collection_config, scorecard_params
      context 'the page with interactions' do
        all_param_values(collection_config).each do |param_hash|
          param_hash.each do |param, value|
            scurcard_params = scorecard_params.deep_dup
            scurcard_params[as_query_param(param).to_sym] = value
            data_attribute = "data-#{param.to_s.gsub('_', '-')}"

            describe_desktop do
              with_shared_context 'click .js-drawTable element with', data_attribute, value.to_s do
                desktop_assertions(collection_config, scurcard_params)
              end
            end
            describe_mobile do
              with_shared_context 'click .js-drawTable element with', data_attribute, value.to_s do
                mobile_assertions(collection_config, scurcard_params)
              end
            end
          end
        end
      end
    end
    all_query_hashes_for(collection_config) do |query_params|
      context "with query params: #{query_params}" do
        scurcard_params = scorecard_params.deep_dup.merge(query_params)
        with_shared_context 'setup community spotlight', query_params do
          include_examples 'basic spotlight assertions', collection_config, scurcard_params
        end
      end
    end
  end
end

shared_example 'should highlight column' do |data_type|
  index = highlight_column_for(data_type)
  expect(community_spotlight_page.desktop_scorecard.table[:class]).to include("highlight#{index}")
end

shared_examples 'basic spotlight assertions' do |collection_config, scorecard_params|
  describe_desktop do
    desktop_assertions(collection_config, scorecard_params)
  end
  describe_mobile do
    mobile_assertions(collection_config, scorecard_params)
  end
end

def desktop_assertions(collection_config, scorecard_params)
  include_example 'should highlight column', scorecard_params[:sortBy]
  include_example 'should have selectpicker with selected value', SUBGROUP_SELECT_DESKTOP_SELECTOR, expected_subgroup_selection(scorecard_params)
  it 'should have the correct query string' do
    expected_query_params(scorecard_params).each do |key, value|
      expect_query_param(as_query_param(key), value) # snake_case => snakeCase
    end
  end
end

def as_query_param(key)
  key.to_s.camelize(:lower)
end

def mobile_assertions(collection_config, scorecard_params)
  include_example 'should have selectpicker with selected value', SUBGROUP_SELECT_MOBILE_SELECTOR, expected_subgroup_selection(scorecard_params)
  include_example 'should have selectpicker with selected value', DATA_TYPE_SELECT_MOBILE_SELECTOR, expected_datatype_selection(scorecard_params)
end

def highlight_column_for(data_type)
  community_spotlight_page.desktop_scorecard.table_headers.index do |header|
    header['data-sort-by'] == data_type
  end
end

def expected_subgroup_selection(scorecard_params)
  CSC_translation_of(scorecard_params[:sortBreakdown])
end

def expected_datatype_selection(scorecard_params)
  CSC_translation_of(scorecard_params[:sortBy])
end

def CSC_translation_of(value)
  I18n.t(value, scope: 'controllers.community_spotlights_controller')
end

def expected_query_params(scorecard_params)
  scorecard_params.select { |k, _| QUERY_PARAM_KEYS.include?(k) }
end

def all_query_hashes_for(collection_config, &block)
  collection_config[:scorecard_fields].each do |field|
    data_type = field[:data_type]
    next if data_type == :school_info
    collection_config[:scorecard_subgroups_list].each do |breakdown|
      [:asc, :desc].each do |sort_type|
        query_params = {
          sort_by: data_type,
          sort_breakdown: breakdown,
          sort_asc_or_desc: sort_type,
        }
        yield(query_params)
      end
    end
  end
end

def all_param_values(collection_config)
  param_values = collection_config[:scorecard_fields].map do |field|
    data_type = field[:data_type]
    unless data_type == :school_info
      { sort_by: data_type }
    end
  end.compact
  param_values += collection_config[:scorecard_subgroups_list].map do |sub|
    { sort_breakdown: sub }
  end
  param_values += [:asc, :desc].map { |sort| { sort_asc_or_desc: sort } }
end
