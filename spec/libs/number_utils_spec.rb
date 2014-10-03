require 'spec_helper'

describe NumberUtils do
  before(:all) do
    class FakeModel
      include NumberUtils
    end
  end
  after(:all) { Object.send :remove_const, :FakeModel }
  let(:target) { FakeModel.new }

  describe '#faster_number_with_precision' do
    describe 'for precision 2' do
      [
          [1   , 1],
          [1.1 , 1.1],
          [1.01, 1.01],
          [1   , 1.001],
          [1   , 1.0049999],
          [1.01, 1.005001],
          [1.05, 1.054999],
          [1.06, 1.055001],
          [1.99, 1.994999],
          [2   , 1.995001]
      ].each do |(output, input)|
        it "gives #{output} if given #{input}" do
          expect(target.faster_number_with_precision(input, 2)).to eq(output)
        end
      end
    end
    describe 'for precision 0' do
      [
          [1, 1],
          [1, 1.1],
          [1, 1.4999],
          [2, 1.5001],
          [2, 1.999],
          [2, 2.4999],
          [3, 2.5001]
      ].each do |(output, input)|
        it "gives #{output} if given #{input}" do
          expect(target.faster_number_with_precision(input, 0)).to eq(output)
        end
      end
    end
  end
end
