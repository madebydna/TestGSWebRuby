require 'spec_helper'

describe CategoryPlacement do

  describe '#parent_enforced_sizes' do
    let(:page) { FactoryGirl.build(:page, name: 'Test') }

    context 'when parent specifies the sizes' do

      before do
        parent_placement = FactoryGirl.create(:category_placement, page: page, layout_config: {
          "child_sizes" => ['sm' => 6, 'md' => 4]
        }.to_json)

        subject.parent = parent_placement
      end

      it 'should return the right sizes' do
        expect(subject.parent_enforced_sizes).to eq({'xs' => 12, 'sm' => 6, 'md' => 4, 'lg' => 12})
      end

    end

  end

end