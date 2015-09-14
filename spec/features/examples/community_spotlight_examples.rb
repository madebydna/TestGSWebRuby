shared_example 'should highlight column' do |number|
  expect(community_spotlight_page.desktop_scorecard.table[:class]).to include("highlight#{number}")
end

shared_example 'should have dropdown with selected value' do |dropdown_selector, value|
  expect(community_spotlight_page.find(dropdown_selector)[:title]).to eq(value)
end

shared_examples 'community spotlight assertions' do |opts|
  subgroup_select_desktop_selector = "[data-id='subgroup-select']"
  subgroup_select_mobile_selector  = "[data-id='subgroup-select-mobile']"
  data_type_select_mobile_selector = "[data-id='data-type-select-mobile']"

  default_params = {
    gradeLevel: 'h',
    schoolType: ['public', 'charter'],
    sortBy: 'a_through_g',
    sortBreakdown: 'hispanic',
    sortAscOrDesc: 'desc',
    offset: 0,
  }.merge(opts[:default_params] || {})
  query_params = opts[:query_params] || {}

  expected_query_params = opts[:expected_query_params] || query_params
  expected_subgroup_selection = opts[:expected_subgroup_selection]
  expected_datatype_selection = opts[:expected_datatype_selection]
  expected_highlight_column   = opts[:expected_highlight_column]

  context "with default params: #{default_params}" do
    let(:default_params) { default_params }

    context "with query params: #{query_params}" do
      let(:query_params) { query_params }
      with_shared_context 'setup community spotlight' do
        context 'the page before interaction' do
          it 'should have the default query string' do
            expected_query_params.each do |key, value|
              expect_query_param(key, value)
            end
          end
          describe_desktop do
            include_example 'should highlight column', expected_highlight_column
            include_example 'should have dropdown with selected value', subgroup_select_desktop_selector, expected_subgroup_selection
          end
          describe_mobile do
            include_example 'should have dropdown with selected value', subgroup_select_mobile_selector, expected_subgroup_selection
            include_example 'should have dropdown with selected value', data_type_select_mobile_selector, expected_datatype_selection
          end
        end
        context 'the page with interactions' do
          describe_desktop do
            with_shared_context 'click .js-drawTable element with', 'data-sort-by', 'graduation_rate' do
              include_example 'should have query parameter', 'sortBy', 'graduation_rate'
              include_example 'should highlight column', 2
            end
            with_shared_context 'click .js-drawTable element with', 'data-sort-breakdown', 'all_students' do
              include_example 'should have dropdown with selected value', subgroup_select_desktop_selector, 'All students'
            end
          end
          describe_mobile do
            with_shared_context 'click .js-drawTable element with', 'data-sort-by', 'graduation_rate' do
              include_example 'should have query parameter', 'sortBy', 'graduation_rate'
              include_example 'should have dropdown with selected value', data_type_select_mobile_selector, 'Graduation Rate'
            end
            with_shared_context 'click .js-drawTable element with', 'data-sort-breakdown', 'all_students' do
              include_example 'should have dropdown with selected value', subgroup_select_mobile_selector, 'All students'
            end
          end
          describe_mobile_and_desktop do
            with_shared_context 'click .js-drawTable element with', 'data-sort-asc-or-desc', 'asc' do
              include_example 'should have query parameter', 'sortAscOrDesc', 'asc'
            end
          end
        end
      end
    end
  end
end
