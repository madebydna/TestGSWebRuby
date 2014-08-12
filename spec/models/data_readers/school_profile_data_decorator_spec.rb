require 'spec_helper'

describe SchoolProfileDataDecorator do
  describe '#footnotes' do
    let(:page) { FactoryGirl.build(:page) }
    subject(:school) { FactoryGirl.build(:school).extend SchoolProfileDataDecorator }
    let(:footnotes_category) { FactoryGirl.build(:category) }

    before do
      @page_config = double('page_config')
      @section = FactoryGirl.create(:section_category_placement, page: page)
      allow(@page_config).to receive(:root_placements).and_return [ @section ]
      @census_category = double('census_category')
    end

    after do
      clean_dbs :profile_config
    end

    it 'should throw an ArgumentError if category or page not provided' do
      expect { subject.footnotes(category: double.as_null_object) }.to raise_error(ArgumentError)
      expect { subject.footnotes(page_config: double.as_null_object) }.to raise_error(ArgumentError)
    end

    it 'should build a map with label and value' do
      group = @section.children.first
      group.title = 'Student ethnicity'
      group.save!

      allow(@page_config).to receive(:category_placement_has_children?).and_return true
      allow(@page_config).to receive(:category_placement_leaves).and_return [ group.children.first ]
      allow(@page_config).to receive(:category_placement_parent).and_return group

      allow(subject).to receive(:footnotes_for_category).and_return(
        [
          source: 'NCES',
          year: '2012'
        ]
      )

      expected = [
        label: 'Student ethnicity',
        value: 'NCES, 2011-2012'
      ]

      expect(subject.footnotes(category: footnotes_category, page_config: @page_config)).to eq expected
    end
  end

end