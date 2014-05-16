require 'spec_helper'

describe CategoryPlacement do

  describe '#parent_enforced_sizes' do
    let(:page) { FactoryGirl.build(:page, name: 'Test') }

    context 'when parent specifies the sizes' do

      before do
        clean_dbs :profile_config
        @section_placement = FactoryGirl.create(:section_category_placement, page: page, layout_config: {
          "child_sizes" => [{'sm' => 6, 'md' => 4}]
        }.to_json)

        @group_placement = @section_placement.children.first

        @group_placement.layout_config = {
          "sizes" => {'xs' => 6, 'sm' => 2, 'md' => 2}
        }.to_json
      end

      after do
        clean_dbs :profile_config
      end

      it 'should return configured sizes merged onto default sizes' do
        expect(@group_placement.my_sizes).to eq({'xs' => 6, 'sm' => 2, 'md' => 2, 'lg' => 12})
      end

      it 'should echo the parent enforced sizes specific in test setup' do
        expect(@group_placement.parent_enforced_sizes).to eq({'sm' => 6, 'md' => 4})
      end

      it 'should return merge sizes onto parent enforced sizes' do
        expect(@group_placement.sizes).to eq({'xs' => 6, 'sm' => 6, 'md' => 4, 'lg' => 12})
      end

    end

  end

end
