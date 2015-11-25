require 'spec_helper'

describe SchoolProfileDataDecorator do

  describe '#data_for_category_and_source' do
    subject(:school) { FactoryGirl.build(:school).extend SchoolProfileDataDecorator }
    let(:category1) { double('category', :id => 1, :source => 'census_data') }
    let(:category2) { double('category', :id => 2, :source => 'census_data') }
    let(:data1) { :data1 }
    let(:data2) { :data2 }

    it 'should be memoized' do
      params1 = {category: category1, source: category1.source}
      params2 = {category: category2, source: category2.source}
      allow(subject).to receive(:census_data).with(params1).once.and_return(data1)
      allow(subject).to receive(:census_data).with(params2).once.and_return(data2)
      expect(subject.data_for_category_and_source(params1)).to eq(data1)
      expect(subject.data_for_category_and_source(params1)).to eq(data1)
      expect(subject.data_for_category_and_source(params2)).to eq(data2)
      expect(subject.data_for_category_and_source(params2)).to eq(data2)
      expect(subject.data_for_category_and_source(params1)).to eq(data1)
    end
  end

  describe 'data readers' do
    subject(:school) { FactoryGirl.build(:school).extend SchoolProfileDataDecorator }
    let(:category1) { double('category', :id => 1) }
    let(:category2) { double('category', :id => 2) }
    # Note the data format was picked because of the enrollment method, which expects hashes with arrays as values.
    # Probably I should have broken that out to a separate spec and kept this simple.
    let(:data1) { {id: [:data1]} }
    let(:data2) { {id: [:data2]} }

    describe 'that rely on category' do
      describe 'should be memoized by category' do
        [
            [:census_data, :@census_data_reader, :labels_to_hashes_map],
            [:cta_prek_only, :@cta_prek_only_data_reader, :data_for_category],
            [:details, :@details_data_reader, :data_for_category],
            [:esp_data_points, :@esp_data_points_data_reader, :data_for_category],
            [:esp_response, :@esp_data_reader, :data_for_category],
            [:group_comparison_data, :@group_comparison_data_reader, :data_for_category],
            [:community_spotlights, :@community_spotlights_data_reader, :data_for_category],
            [:snapshot, :@snapshot_data_reader, :data_for_category],
            [:performance, :@performance_data_reader, :data_for_category],
            [:nearby_schools, :@nearby_schools_data_reader, :data_for_category],
            [:enrollment, :@esp_data_reader, :responses_for_category],
        ].each do |method, reader_class, reader_action|
          it "##{method.to_s}" do
            reader = double(reader_class)
            subject.instance_variable_set(reader_class, reader)
            allow(reader).to receive(reader_action).with(category1).once.and_return(data1)
            allow(reader).to receive(reader_action).with(category2).once.and_return(data2)
            expect(subject.send(method, {category:category1})).to eq(data1)
            expect(subject.send(method, {category:category1})).to eq(data1)
            expect(subject.send(method, {category:category2})).to eq(data2)
            expect(subject.send(method, {category:category2})).to eq(data2)
            expect(subject.send(method, {category:category1})).to eq(data1)
          end
        end
      end
    end
    describe 'that do not rely on category' do
      describe 'should be memoized' do
        [
            [:census_data_points, :@census_data_reader, :data_type_descriptions_to_school_values_map],
            [:test_scores, :@test_scores_data_reader, :data],
            [:rating_data, :@rating_data_reader, :data],
        ].each do |method, reader_class, reader_action|
          it "##{method.to_s}" do
            reader = double(reader_class)
            subject.instance_variable_set(reader_class, reader)
            allow(reader).to receive(reader_action).once.and_return(data1)
            expect(subject.send(method, {category:category1})).to eq(data1)
            expect(subject.send(method, {category:category1})).to eq(data1)
            expect(subject.send(method, {category:category2})).to eq(data1)
            expect(subject.send(method, {category:category2})).to eq(data1)
            expect(subject.send(method, {category:category1})).to eq(data1)
          end
        end
      end
    end
  end

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

    context 'with valid data' do
      before do
        group = @section.children.first
        group.title = 'Student ethnicity'
        group.save!

        allow(@page_config).to receive(:category_placement_has_children?).and_return true
        allow(@page_config).to receive(:category_placement_leaves).and_return [ group.children.first ]
        allow(@page_config).to receive(:category_placement_parent).and_return group
      end
      it 'should build a map with label and value' do

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

      it 'should build the correct value when year is 0' do
        allow(subject).to receive(:footnotes_for_category).and_return(
          [
            source: 'Manually entered',
            year: '0'
          ]
        )

        expected = [
          label: 'Student ethnicity',
          value: 'Manually entered'
        ]

        expect(subject.footnotes(category: footnotes_category, page_config: @page_config)).to eq expected
      end
    end
  end

end
