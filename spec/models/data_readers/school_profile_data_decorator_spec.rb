require 'spec_helper'

describe SchoolProfileDataDecorator do
  describe '#footnotes' do
    let(:page) { FactoryGirl.build(:page) }
    subject(:school) { FactoryGirl.build(:school).extend SchoolProfileDataDecorator }
    let(:footnotes_category) { FactoryGirl.build(:category) }

    before do
      @page_config = double('page_config')
      @section = FactoryGirl.create(:section_category_placement, page: page)
      @page_config.stub(:root_placements).and_return [ @section ]
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

      @page_config.stub(:category_placement_has_children?).and_return true
      @page_config.stub(:category_placement_leaves).and_return [ group.children.first ]
      @page_config.stub(:category_placement_parent).and_return group

      subject.stub(:footnotes_for_category).and_return(
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
  
  describe '#facebook_url' do
    subject(:school) { FactoryGirl.build(:school).extend SchoolProfileDataDecorator }
    it 'should return a url if the school has a facebook url' do
      school_metadata = Hashie::Mash.new(:facebook_url => 'http://facebook.com/pages/myschool/12345')
      school.stub(:school_metadata).and_return(school_metadata)
      expect(school.facebook_url).to eq 'http://facebook.com/pages/myschool/12345'
    end
    it 'should return nil if the school does not have a facebook url' do
      school_metadata = Hashie::Mash.new(:facebook_url => '')
      school.stub(:school_metadata).and_return(school_metadata)
      expect(school.facebook_url).to be_nil

      school_metadata = Hashie::Mash.new
      school.stub(:school_metadata).and_return(school_metadata)
      expect(school.facebook_url).to be_nil
    end
  end
end
