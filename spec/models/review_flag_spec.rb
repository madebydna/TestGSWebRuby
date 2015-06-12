require 'spec_helper'
require_relative 'examples/model_with_active_field'

describe ReviewFlag do
  it { is_expected.to be_a(ReviewFlag) }
  it_behaves_like 'model with active field'

  describe '#member_id' do
    it 'can be mass-assigned' do
      flag = ReviewFlag.new(member_id: 1)
      expect(flag.member_id).to eq(1)
    end
  end

end