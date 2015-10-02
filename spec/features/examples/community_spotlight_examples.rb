require 'features/selectors/community_spotlight_page'
require 'features/contexts/community_spotlight_contexts'
require 'features/examples/url_examples'

shared_examples 'community spotlight assertions' do |collection_config|
  SUBGROUP_SELECT_DESKTOP_SELECTOR = "[data-id='subgroup-select']"
  SUBGROUP_SELECT_MOBILE_SELECTOR  = "[data-id='subgroup-select-mobile']"
  DATA_TYPE_SELECT_MOBILE_SELECTOR = "[data-id='data-type-select-mobile']"
  QUERY_PARAM_KEYS = [:sortBy, :sortBreakdown, :sortAscOrDesc]

  let(:collection_config) { collection_config }
  scorecard_params = collection_config[:scorecard_params]

  context "with default params: #{scorecard_params}" do

    with_shared_context 'setup community spotlight' do
      context 'the page before interaction' do
        describe_desktop do
          desktop_assertions(collection_config, scorecard_params)
        end
        describe_mobile do
          mobile_assertions(collection_config, scorecard_params)
        end
      end
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
  end
end

shared_example 'should highlight column' do |number|
  expect(community_spotlight_page.desktop_scorecard.table[:class]).to include("highlight#{number}")
end

shared_example 'should have dropdown with selected value' do |dropdown_selector, value|
  expect(community_spotlight_page.find(dropdown_selector)[:title]).to eq(value)
end

def desktop_assertions(collection_config, scorecard_params)
  include_example 'should highlight column', expected_highlight_column(collection_config, scorecard_params)
  include_example 'should have dropdown with selected value', SUBGROUP_SELECT_DESKTOP_SELECTOR, expected_subgroup_selection(scorecard_params)
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
  include_example 'should have dropdown with selected value', SUBGROUP_SELECT_MOBILE_SELECTOR, expected_subgroup_selection(scorecard_params)
  include_example 'should have dropdown with selected value', DATA_TYPE_SELECT_MOBILE_SELECTOR, expected_datatype_selection(scorecard_params)
end

def highlight_column_for(collection_config, data_type)
  collection_config[:scorecard_fields].index do |f|
    f[:data_type] == data_type
  end
end

def expected_subgroup_selection(scorecard_params)
  CSC_translation_of(scorecard_params[:sortBreakdown])
end

def expected_datatype_selection(scorecard_params)
  CSC_translation_of(scorecard_params[:sortBy])
end

def expected_highlight_column(collection_config, scorecard_params)
  highlight_column_for(collection_config, scorecard_params[:sortBy])
end

def CSC_translation_of(value)
  I18n.t(value, scope: 'controllers.community_spotlights_controller')
end

def expected_query_params(scorecard_params)
  scorecard_params.select { |k, _| QUERY_PARAM_KEYS.include?(k) }
end

def all_param_values(collection_config)
  all_param_values = collection_config[:scorecard_fields].map do |field|
    data_type = field[:data_type]
    unless data_type == :school_info
      { sort_by: data_type }
    end
  end.compact
  all_param_values += collection_config[:scorecard_subgroups_list].map do |sub|
    { sort_breakdown: sub }
  end
  all_param_values += [:asc, :desc].map { |sort| { sort_asc_or_desc: sort } }
end
