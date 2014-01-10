require 'spec_helper'

describe CategoryPlacement do

  describe '#parent_enforced_sizes' do
    let(:page) { FactoryGirl.build(:page, name: 'Test') }

    context 'when parent specifies the sizes' do

      before do
        parent_placement = FactoryGirl.create(:category_placement, page: page, layout_config: {
          "child_sizes" => [{'sm' => 6, 'md' => 4}]
        }.to_json)

        subject.layout_config = {
          "sizes" => {'xs' => 6, 'sm' => 2, 'md' => 2}
        }.to_json

        subject.parent = parent_placement
      end

      it 'should return configured sizes merged onto default sizes' do
        expect(subject.my_sizes).to eq({'xs' => 6, 'sm' => 2, 'md' => 2, 'lg' => 12})
      end

      it 'should echo the parent enforced sizes specific in test setup' do
        expect(subject).to receive(:siblings).and_return([subject])
        expect(subject.parent_enforced_sizes).to eq({'sm' => 6, 'md' => 4})
      end

      it 'should return merge sizes onto parent enforced sizes' do
        expect(subject).to receive(:siblings).and_return([subject])
        expect(subject.sizes).to eq({'xs' => 6, 'sm' => 6, 'md' => 4, 'lg' => 12})
      end

    end

  end

end