require 'spec_helper'

describe 'state ratings partial' do
  it 'displays the state rating' do
    rating_data = {
      'state_rating' => {
        'description' => 'rspec description',
        'overall_rating' => 'rspec overall rating'
      }
    }

    render :partial => 'data_layouts/state_ratings', :locals => { data: rating_data }

    expect(rendered).to match '<h5>State Rating</h5>'
    expect(rendered).to match 'rspec overall rating'
    expect(rendered).to match 'rspec description'
  end

  it 'displays nothing if state rating not provided' do
    rating_data = {
      'state_data' => nil
    }
    render :partial => 'data_layouts/state_ratings', :locals => { data: rating_data }
    expect(rendered).to eq ''

    rating_data = {}
    render :partial => 'data_layouts/state_ratings', :locals => { data: rating_data }
    expect(rendered).to eq ''
  end

end