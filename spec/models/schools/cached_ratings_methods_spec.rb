require 'spec_helper'

describe CachedRatingsMethods do
  before(:all) do
    class FakeModel
      include CachedRatingsMethods
    end
  end
  after(:all) { Object.send :remove_const, :FakeModel }
  let(:model) { FakeModel.new }

  describe '#ratings_matching_criteria' do
    subject { model.ratings_matching_criteria(ratings, criteria) }
    let(:ratings) do
      [
        {
          a: 1,
          b: 2,
          c: 3
        },
        {
          a: 4,
          b: 5,
          c: 6
        }
      ]
    end

    context 'with nil criteria' do
      let(:criteria) do
        {
          b: 2,
          c: nil
        }
      end
      it { is_expected.to eq([{a: 1, b: 2, c: 3}]) }
    end

    context 'with multiple criteria' do
      let(:criteria) do
        {
          a: 4,
          c: 6
        }
      end
      it { is_expected.to eq([{a: 4, b: 5, c: 6}]) }
    end
  end
end
