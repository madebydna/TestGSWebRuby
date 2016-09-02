
require 'spec_helper'

describe 'school_profile/_nearby_school' do
  let(:valid_props) do
    {
      score: 1,
      state_score: 1,
      score_rating: 1
    }
  end

  def render_partial(props)
    render partial: 'school_profiles/person_bar_viz', locals: props
  end

  (1..10).to_a.each do |input|
    describe "when valid score_rating is #{input}" do
      it 'renders the visualization' do
        render_partial(valid_props.merge(score_rating: input))
        expect(rendered).to have_css('.person-bar-viz')
      end
    end
  end

  [-1, 0, 11].each do |input|
    describe "when invalid score_rating is #{input}" do
      it 'renders nothing' do
        render_partial(valid_props.merge(score_rating: input))
        expect(rendered.strip).to be_empty
      end
    end
  end

  (1..100).to_a.each do |input|
    describe "when valid score is #{input}" do
      it 'renders the visualization' do
        render_partial(valid_props.merge(score: input))
        expect(rendered).to have_css('.person-bar-viz')
      end
    end
  end

  [-1, 0, 101].each do |input|
    describe "when invalid score is #{input}" do
      it 'renders nothing' do
        render_partial(valid_props.merge(score: input))
        expect(rendered.strip).to be_empty
      end
    end
  end

end
