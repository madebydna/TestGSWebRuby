require 'spec_helper'

describe 'school_profile/_person_bar_viz' do
  let(:visualization_class) { '.person-bar-viz' }
  let(:state_visualization_class) { '.arrow-up' }
  let(:valid_props) do
    {
        score_data: {
            score: SchoolProfiles::DataPoint.new('90'),
            state_score: 1,
            range:(0..100),
            score_label:'English',
            info_text:'tooltip content'
        }
    }
  end

  def props(value)
    p = valid_props.clone
    p[:score_data] = OpenStruct.new(p[:score_data]).tap { |s| s.score = value }
    p
  end

  def render_partial(props)
    stub_template "_ten_person_icons.html.erb" => "persons"
    stub_template "_info_circle.html.erb" => "info_text"
    render partial: 'school_profiles/person_bar_viz', locals: props
  end

  # describe 'score' do
  #   [0,1,14,37,50,88,99,100].each do |input|
  #     it 'renders the visualization' do
  #       score_data = SchoolProfiles::RatingScoreItem.new.tap do |rsi|
  #         rsi.score = SchoolProfiles::DataPoint.new(input)
  #       end
  #       render_partial(props(score_data: score_data))
  #       expect(rendered).to have_css(visualization_class)
  #     end
  #   end
  #
  #
  #   [-1, 101].each do |input|
  #     describe "when invalid score is #{input}" do
  #       it 'renders nothing' do
  #         score_data = SchoolProfiles::RatingScoreItem.new.tap do |rsi|
  #           rsi.score = SchoolProfiles::DataPoint.new(input)
  #         end
  #         render_partial(props(score_data: score_data))
  #         expect(rendered.strip).to be_empty
  #       end
  #     end
  #   end
  #
  #   describe 'when score is nil' do
  #     it 'renders nothing' do
  #       score_data = SchoolProfiles::RatingScoreItem.new.tap do |rsi|
  #         rsi.score = SchoolProfiles::DataPoint.new(nil)
  #       end
  #       render_partial(props(score_data: score_data))
  #       expect(rendered.strip).to be_empty
  #     end
  #   end
  # end

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
        render_partial(props(SchoolProfiles::DataPoint.new(score)))
        expect(rendered).to have_css(".rating_color_#{expected_rating}")
      end
    end
  end

  # describe 'state average' do
  #   describe 'when within range' do
  #     it 'renders the arrow' do
  #       score_data = SchoolProfiles::RatingScoreItem.new.tap do |rsi|
  #         rsi.score = SchoolProfiles::DataPoint.new(60)
  #       end
  #       render_partial(props(score_data: score_data))
  #       expect(rendered).to have_css(state_visualization_class)
  #     end
  #   end
  #
  #   describe 'when outside range' do
  #     it 'renders score visualization, but no state average arrow' do
  #       render_partial(valid_props.merge(state_score: 101))
  #       expect(rendered.strip).not_to be_empty
  #       expect(rendered).not_to have_css(state_visualization_class)
  #     end
  #   end
  #
  #   describe 'when nil' do
  #     it 'renders score visualization, but no state average arrow' do
  #       render_partial(valid_props.merge(state_score: nil))
  #       expect(rendered.strip).not_to be_empty
  #       expect(rendered).not_to have_css(state_visualization_class)
  #     end
  #   end
  # end
  #
  # describe 'when custom ranges are specified' do
  #   # let(:props) { valid_props.merge(range: (600..2400)) }
  #
  #   it 'valid score is rendered' do
  #     score_data = SchoolProfiles::RatingScoreItem.new.tap do |rsi|
  #       rsi.score = SchoolProfiles::DataPoint.new(input)
  #       rsi.state_score = 1500
  #       rsi.range = (600..2400)
  #     end
  #     render_partial(props(score_data: score_data))
  #     # render_partial(props.merge(score: 1553, state_score: 1500))
  #     expect(rendered).to have_css(visualization_class)
  #   end
  #
  #   it 'valid state average is rendered' do
  #     score_data = SchoolProfiles::RatingScoreItem.new.tap do |rsi|
  #       rsi.score = SchoolProfiles::DataPoint.new(input)
  #       rsi.state_score = 1500
  #       rsi.range = (600..2400)
  #     end
  #     render_partial(props(score_data: score_data))
  #     expect(rendered).to have_css(state_visualization_class)
  #   end
  #
  #   it 'values outside range are not rendered' do
  #     render_partial(props)
  #     expect(rendered.strip).to be_empty
  #   end
  #
  #   it 'state average arrow when outside range is not rendered' do
  #     score_data = SchoolProfiles::RatingScoreItem.new.tap do |rsi|
  #       rsi.score = SchoolProfiles::DataPoint.new(input)
  #       rsi.state_score = 65
  #       rsi.range = (600..2400)
  #     end
  #     render_partial(props(score_data: score_data))
  #     expect(rendered.strip).not_to be_empty
  #     expect(rendered).not_to have_css(state_visualization_class)
  #   end
  # end
end
