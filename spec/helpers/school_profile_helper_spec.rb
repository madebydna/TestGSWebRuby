require 'spec_helper'

describe SchoolProfileHelper do
  describe '#category_placement_anchor' do
    let(:category_placement) {
      FactoryGirl.build(:category_placement, id: 1, title: 'A title', category: FactoryGirl.build(:category))
    }

    it 'should use the category placement title if available' do
      expect(helper.category_placement_anchor(category_placement)).to eq 'A_title'
    end

    it 'should use the category name if there is no title' do
      category_placement.title = nil
      expect(helper.category_placement_anchor(category_placement)).to eq 'Test_category'
    end
  end
end
