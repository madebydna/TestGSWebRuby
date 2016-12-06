require 'spec_helper'

describe 'school_profile/_person_bar_viz' do
  let(:visualization_class) { '.person-bar-viz' }
  let(:state_visualization_class) { '.arrow-down' }
  let(:valid_props) do
    {
        score: 1,
        state_score: 1
    }
  end

  def render_partial(props)
    render partial: 'school_profiles/person_bar_viz', locals: props
  end

  describe 'score' do
    [0,1,14,37,50,88,99,100].each do |input|
      describe "when valid score is #{input}" do
        it 'renders the visualization' do
          render_partial(valid_props.merge(score: input))
          expect(rendered).to have_css(visualization_class)
        end
      end
    end

    [-1, 101].each do |input|
      describe "when invalid score is #{input}" do
        it 'renders nothing' do
          render_partial(valid_props.merge(score: input))
          expect(rendered.strip).to be_empty
        end
      end
    end

    describe 'when score is nil' do
      it 'renders nothing' do
        render_partial(valid_props.merge(score: nil))
        expect(rendered.strip).to be_empty
      end
    end
  end

  describe 'score_rating' do
    {
        0 => 1,
        9 => 1,
        10 => 2,
        50 => 6,
        89 => 9,
        90 => 10,
        100 => 10
    }.each do |score, expected_rating|
      it "renders #{expected_rating} when score is #{score}" do
        render_partial(valid_props.merge(score: score))
        expect(rendered).to have_css(".rating_color_#{expected_rating}")
      end
    end
  end

  describe 'state average' do
    describe 'when within range' do
      it 'renders the arrow' do
        render_partial(valid_props)
        expect(rendered).to have_css(state_visualization_class)
      end
    end

    describe 'when outside range' do
      it 'renders score visualization, but no state average arrow' do
        render_partial(valid_props.merge(state_score: 101))
        expect(rendered.strip).not_to be_empty
        expect(rendered).not_to have_css(state_visualization_class)
      end
    end

    describe 'when nil' do
      it 'renders score visualization, but no state average arrow' do
        render_partial(valid_props.merge(state_score: nil))
        expect(rendered.strip).not_to be_empty
        expect(rendered).not_to have_css(state_visualization_class)
      end
    end
  end

  describe 'when custom ranges are specified' do
    let(:props) { valid_props.merge(range: (600..2400)) }

    it 'valid score is rendered' do
      render_partial(props.merge(score: 1553, state_score: 1500))
      expect(rendered).to have_css(visualization_class)
    end

    it 'valid state average is rendered' do
      render_partial(props.merge(score: 1553, state_score: 1500))
      expect(rendered).to have_css(state_visualization_class)
    end

    it 'values outside range are not rendered' do
      render_partial(props)
      expect(rendered.strip).to be_empty
    end

    it 'state average arrow when outside range is not rendered' do
      render_partial(props.merge(score: 1553, state_score: 65))
      expect(rendered.strip).not_to be_empty
      expect(rendered).not_to have_css(state_visualization_class)
    end
  end
end
