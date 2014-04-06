require 'spec_helper'
describe PageConfig do


  context 'With page that has shuffled category placements' do
    let(:page) { FactoryGirl.build(:page, name: 'Test') }

    before do
      all_placements = []
      @roots = FactoryGirl.create_list(:category_placement, 3, page: page)
      @roots[0].position = 99
      @roots.each do |root|
        more_placements = FactoryGirl.build_list(:category_placement, 3, page: page)
        more_placements.each { |placement| root.children << placement; placement.parent = root; placement.save! }
        all_placements += more_placements
      end
      all_placements += @roots

      Page.stub(:by_name).with('Test').and_return(page)
      @page_config = PageConfig.new page.name, all_placements.shuffle
    end

    describe '#root_placements' do
      it 'should return the right number of items' do
        pending 'investigate intermittent failure'
        expect(@page_config.root_placements.length).to eq(3)
      end

      it 'should return only root nodes' do
        @roots = @page_config.root_placements
        @roots.each do |item|
          expect(item).to be_root
        end
      end
    end

  end

end