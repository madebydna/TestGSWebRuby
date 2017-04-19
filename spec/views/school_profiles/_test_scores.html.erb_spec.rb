require 'spec_helper'

describe 'school_profiles/_test_scores' do
  let(:valid_props) do
    {
      title: 'Foo Title',
      subtitle: 'Foo Subtitle',
      test_scores: {
        rating: nil,
        info_text: 'Info text',
        subject_scores: [],
        content: nil
      }
    }
  end

  def props(test_scores)
    p = valid_props.clone
    p[:test_scores] = OpenStruct.new(p[:test_scores].merge(test_scores))
    p
  end

  def render_partial(props)
    render partial: 'school_profiles/test_scores', locals: props
  end

  context 'when there are no data values given' do
    subject do
      render_partial(props(data_values: []))
      rendered
    end
    it { is_expected.to have_text('Data is not available') }
  end

  context 'when there are multiple tests with same subject' do
    subject do
      data_values = [
        SchoolProfiles::RatingScoreItem.new.tap do |rsi|
          rsi.label = 'Math'
          rsi.score = SchoolProfiles::DataPoint.new('90')
          rsi.test_label = 'Test A'
        end,
        SchoolProfiles::RatingScoreItem.new.tap do |rsi|
          rsi.label = 'Science'
          rsi.score = SchoolProfiles::DataPoint.new('80')
          rsi.test_label = 'Test A'
        end,
        SchoolProfiles::RatingScoreItem.new.tap do |rsi|
          rsi.label = 'Math'
          rsi.score = SchoolProfiles::DataPoint.new('70')
          rsi.test_label = 'Test B'
        end
      ]
      render_partial(props(subject_scores: data_values))
      rendered
    end
    it { is_expected.to have_text('Test A') }
    it { is_expected.to have_text('Test B') }
  end

  context 'when there are NOT multiple tests with same subject' do
    subject do
      data_values = [
        SchoolProfiles::RatingScoreItem.new.tap do |rsi|
          rsi.label = 'Math'
          rsi.score = SchoolProfiles::DataPoint.new('90')
          rsi.test_label = 'Test A'
        end,
        SchoolProfiles::RatingScoreItem.new.tap do |rsi|
          rsi.label = 'Science'
          rsi.score = SchoolProfiles::DataPoint.new('80')
          rsi.test_label = 'Test B'
        end
      ]
      render_partial(props(subject_scores: data_values))
      rendered
    end
    it { is_expected.to_not have_text('Test A') }
    it { is_expected.to_not have_text('Test B') }
  end


end
