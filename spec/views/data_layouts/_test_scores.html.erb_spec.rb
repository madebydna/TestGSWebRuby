require 'spec_helper'

describe 'deprecated_school_profile/data_layouts/_test_scores.html.erb' do

  let(:data) { {} }
  let(:category_placement) { FactoryGirl.create(:leaf_category_placement_no_parent) }

  before do
    view.extend(UrlHelper)
    assign(:page_config, double('page_config').as_null_object)
    stub_template '_col.html.erb' => '<%= yield %>'
    stub_template 'shared/_section_header.html.erb' => '<br/>'
    assign(:school, FactoryGirl.build(:alameda_high_school))
  end

  after do
    clean_models CategoryPlacement, Category, CategoryData, Page
  end

  it "doesn't error when data is empty" do
    allow_any_instance_of(BarCharts::BasicBarChart).to receive(:script_tag).and_return(nil)
    expect do
      render partial: 'deprecated_school_profile/data_layouts/test_scores',
             locals: {
               category: category_placement.category,
               category_placement: category_placement,
               data: data
             }
    end.to_not raise_error
  end

  context 'when given empty data' do
    let(:data) do
      {}
    end

    it "doesn't raise an error" do
      allow_any_instance_of(BarCharts::BasicBarChart).to receive(:script_tag).and_return(nil)
      expect do
        render partial: 'deprecated_school_profile/data_layouts/test_scores',
               locals: {
                 category: category_placement.category,
                 category_placement: category_placement,
                 data: data
               }
      end.to_not raise_error
    end
  end

  context 'given a data hash with a key but no value' do
    let(:data) do
      {
        foo: nil
      }
    end
    it "doesn't raise an error" do
      allow_any_instance_of(BarCharts::BasicBarChart).to receive(:script_tag).and_return(nil)
      expect do
        render partial: 'deprecated_school_profile/data_layouts/test_scores',
               locals: {
                 category: category_placement.category,
                 category_placement: category_placement,
                 data: data
               }
      end.to_not raise_error
    end
  end

  context 'given a data hash has no :All entry' do
    let(:data) do
      {
        foo: {}
      }
    end
    it "doesn't raise an error" do
      allow_any_instance_of(BarCharts::BasicBarChart).to receive(:script_tag).and_return(nil)
      expect do
        render partial: 'deprecated_school_profile/data_layouts/test_scores',
               locals: {
                 category: category_placement.category,
                 category_placement: category_placement,
                 data: data
               }
      end.to_not raise_error
    end
  end

end
