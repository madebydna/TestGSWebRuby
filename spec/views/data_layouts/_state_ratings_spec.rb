require 'spec_helper'

describe 'state ratings partial' do
  let(:school) { FactoryGirl.build(:school, state: "MI")}
  let(:category_placement) { FactoryGirl.build(:category_placement) }
  before do
    view.instance_variable_set(:@school, school)
  end
  it 'displays the state rating' do
    rating_data = {
      'state_rating' => {
        'page' => 'overview',
        'label' => 'State Rating',
        'description' => 'rspec description',
        'overall_rating' => 'rspec overall rating'
      }
    }

    render :partial => 'data_layouts/state_ratings', locals: {
      data: rating_data, category_placement: category_placement
    }

    expect(rendered).to match 'State Rating'
    expect(rendered).to match 'rspec overall rating'
    expect(rendered).to match 'rspec description'
  end

  it 'displays nothing if state rating not provided' do
    rating_data = {
      'state_data' => nil
    }
    render :partial => 'data_layouts/state_ratings', locals: {
      data: rating_data, category_placement: category_placement
    }
    expect(rendered.strip).to eq ''

    rating_data = {}
    render :partial => 'data_layouts/state_ratings', locals: {
      data: rating_data, category_placement: category_placement
    }
    expect(rendered.strip).to eq ''
  end

end