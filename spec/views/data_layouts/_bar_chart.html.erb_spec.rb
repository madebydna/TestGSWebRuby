require 'spec_helper'

describe 'school_profile/data_layouts/_bar_chart.html.erb' do

  let(:data) { {} }
  let(:category_placement) { FactoryGirl.create(:leaf_category_placement_no_parent) }

  before do
    view.extend(UrlHelper)
    assign(:page_config, double('page_config').as_null_object)
  end

  after do
    clean_models CategoryPlacement, Category, CategoryData, Page
  end

  it "doesn't error when data is empty" do
    stub_template "_col.html.erb" => '<br/>'
    stub_template "_about_this_data.html.erb" => '<br/>'
    allow_any_instance_of(BarCharts::BasicBarChart).to receive(:script_tag).and_return(nil)
    expect do
      render partial: 'deprecated_school_profile/data_layouts/bar_chart', locals: { category: category_placement.category, category_placement: category_placement, data: data }
    end.to_not raise_error
  end

end
