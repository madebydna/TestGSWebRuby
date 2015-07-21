require 'spec_helper'
require_relative 'search_spec_helper'

feature 'Search filters submission', js: true do
  include SearchSpecHelper
  include UrlHelper

  context 'when selecting a regular checkbox filter' do
    hard_filters = { 'st[]' => :public }
    soft_filters = { 'class_offerings[]' => :ap, 'school_focus[]' => :waldorf, 'beforeAfterCare[]' => :before }

    [hard_filters, soft_filters].each do |filters|
      filters.each do |name, value|
        context "clicking a filter like #{name}=#{value}" do

          let(:checkbox_xpath) { filters_checkbox_xpath(name, value) }

          before do
            set_up_city_browse('de','dover')
            open_full_filter_dialog
            checkbox = page.all(:xpath, checkbox_xpath).last
            checkbox.click
            submit_filters
            open_full_filter_dialog
            page
          end

          it 'should still be clicked after page load' do
            checkbox = page.all(:xpath, checkbox_xpath).last
            expect(checkbox[:class]).to include('i-16-blue-check-box')
          end

          it 'should alter the url' do
            param = encode_square_brackets("#{name}=#{value}")
            expect(current_url).to include(param)
          end
        end
      end

    end
  end

  context 'when selecting a nested checkbox filter' do
    filter_hierarchy = { 'World languages' => { 'class_offerings[]' => :french },
                         'World language immersion' => { 'school_focus[]' => :german } }

    filter_hierarchy.each do |filter_type, filters|
      filters.each do |name, value|
        context "clicking a filter like #{name}=#{value}" do

          let(:checkbox_xpath) { filters_checkbox_xpath(name, value) }

          before do
            set_up_city_browse('de','dover')
            open_full_filter_dialog
            checkbox_accordian(filter_type).click
            page.all(:xpath, checkbox_xpath).last.click
            submit_filters
            open_full_filter_dialog
          end

          it 'should still be clicked after page load' do
            checkbox_accordian(filter_type).click
            checkbox = page.all(:xpath, checkbox_xpath).last
            expect(checkbox[:class]).to include('i-16-blue-check-box')
          end

          it 'should alter the url' do
            param = encode_square_brackets("#{name}=#{value}")
            expect(current_url).to include(param)
          end
        end
      end
    end

  end

  context 'when selecting a sports filters' do

    sports = [:soccer, :basketball]
    # sports = [:soccer]

    [:boys, :girls].each do |gender|
      # [:girls].each do |gender|

      context "for #{gender}" do

        sports.each do |sport|

          context "choosing the #{gender}-#{sport} filter" do

            before do
              set_up_city_browse('de','dover')
              open_full_filter_dialog
              page.all(:xpath, "//div[@data-gs-checkbox-category='#{gender}_sports[]' and @data-gs-checkbox-value='#{sport}']").last.click
              submit_filters
              open_full_filter_dialog
              page
            end

            it 'should still be clicked after page load' do
              expect(page).to have_css("span.i-24-#{sport}-on")
            end

            it 'should alter the url' do
              param = encode_square_brackets("#{gender}_sports[]=#{sport}")
              expect(current_url).to include(param)
            end
          end
        end
      end
    end
  end

  context 'when selecting a dropdown filter' do

    grades = { 'Preschool' => 'p', '1st Grade' => '1'}
    grades.each do |grade, grade_value|
      context "for #{grade}" do
        before do
          set_up_city_browse('de','dover')
          open_filter_dialog
          page.all(:css, 'select.js-grades-select-box').last.select(grade)
          submit_filters
          page
        end

        it 'should still be selected after page load' do
          open_filter_dialog
          select_value = find(:css, 'select.js-grades-select-box').value
          expect(select_value).to eq(grade_value)
        end

      end
    end
  end

  context 'Bay Area-specific filters' do
    soft_filters = { 'summer_program[]' => :yes }
    [soft_filters].each do |filters|
      filters.each do |name, value|
        context "clicking the #{name} filter" do
          let(:checkbox_xpath) { filters_checkbox_xpath(name, value) }

          ['Oakland', 'San Francisco'].each do |city|
            context "in #{city}" do
              before do
                set_up_city_browse('ca', city)
                open_full_filter_dialog
                checkbox = page.all(:xpath, checkbox_xpath).last
                checkbox.click
                submit_filters
                open_full_filter_dialog
                page
              end

              it 'should still be clicked after page load' do
                checkbox = page.all(:xpath, checkbox_xpath).last
                expect(checkbox[:class]).to include('i-16-blue-check-box')
              end

              it 'should alter the url' do
                param = encode_square_brackets("#{name}=#{value}")
                expect(current_url).to include(param)
              end
            end
          end
        end
      end
    end
  end

  context 'Indianapolis filters' do
    filters = { 'ptq_rating[]' => :level_1, 'enrollment[]' => :vouchers }
    [filters].each do |filter_name_value|
      filter_name_value.each do |name, value|
        context "clicking the #{name} filter" do
          let(:checkbox_xpath) { filters_checkbox_xpath(name, value) }

          before do
            set_up_city_browse('in', 'Indianapolis')
            open_full_filter_dialog
            checkbox = page.all(:xpath, checkbox_xpath).last
            checkbox.click
            submit_filters
            open_full_filter_dialog
            page
          end

          it 'should still be clicked after page load' do
            checkbox = page.all(:xpath, checkbox_xpath).last
            expect(checkbox[:class]).to include('i-16-blue-check-box')
          end

          it 'should alter the url' do
            param = encode_square_brackets("#{name}=#{value}")
            expect(current_url).to include(param)
          end
        end
      end
    end
  end

  context 'Detroit filters' do
    filters = { 'cgr[]' => :'70_TO_100', 'gstq_rating[]' => :'1' }
    [filters].each do |filter_name_value|
      filter_name_value.each do |name, value|
        context "clicking the #{name} filter" do
          let(:checkbox_xpath) { filters_checkbox_xpath(name, value) }

          before do
            set_up_city_browse('mi', 'Detroit')
            open_full_filter_dialog
            checkbox = page.all(:xpath, checkbox_xpath).last
            checkbox.click
            submit_filters
            open_full_filter_dialog
            page
          end

          it 'should still be clicked after page load' do
            checkbox = page.all(:xpath, checkbox_xpath).last
            expect(checkbox[:class]).to include('i-16-blue-check-box')
          end

          it 'should alter the url' do
            param = encode_square_brackets("#{name}=#{value}")
            expect(current_url).to include(param)
          end
        end
      end
    end
  end
end
