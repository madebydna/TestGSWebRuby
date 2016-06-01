require 'spec_helper'

describe CommunityScorecardData do
  let(:scorecard_fields) {
    [
      { data_type: :school_info, partial: :school_info },
      { data_type: :a_through_g, partial: :percent_value, year: 2014, state_average: {all: 50} },
      { data_type: :graduation_rate, partial: :percent_value, year: 2013 },
    ]
  }
  let(:school_data_params) do
    { data_sets: [:school_info, :a_through_g, :graduation_rate] }
  end
  let(:collection_struct) { Struct.new(:scorecard_fields, :id) }
  let(:data_sets) { ['a_through_g', 'graduation_rate'] }

  subject { CommunityScorecardData.new }

  describe '#school_data' do
    it 'should use SchoolDataHash to get school info' do
      pending('TODO: mock out solr result for spec')
      fake_object = Object.new
      allow(SchoolDataHash).to receive(:new).and_return(fake_object)
      allow(fake_object).to receive(:data_hash)
      structed_collection = collection_struct.new(scorecard_fields)
      allow(Collection).to receive(:find).and_return(structed_collection)
      allow(subject).to receive(:add_data_explanations!)
      allow(subject).to receive(:school_data_params).and_return(school_data_params)
      allow(subject).to receive(:get_cachified_schools).and_return([1,2,3,4])
      expect(SchoolDataHash).to receive(:new).exactly(4).times
      subject.school_data
    end
  end

  describe '#data_sets_with_years' do
    it 'should create the correct structure' do
      [
        [scorecard_fields, { a_through_g: 2014, graduation_rate: 2013 }.with_indifferent_access],
        [scorecard_fields.reverse, { graduation_rate: 2013, a_through_g: 2014 }.with_indifferent_access]
      ].each do |scorecard_field_set, correct_structure|
        structed_collection = collection_struct.new(scorecard_field_set)
        allow(Collection).to receive(:find).and_return(structed_collection)
        allow(subject).to receive(:school_data_params).and_return(school_data_params)
        expect(subject.send(:data_sets_with_years)).to eq(correct_structure)
      end
    end
  end

  describe '#header_data' do
    before do
      structed_collection = collection_struct.new(scorecard_fields, 15)
      allow(Collection).to receive(:find).and_return(structed_collection)
      allow(subject).to receive(:school_data_params).and_return(school_data_params)
      allow(subject).to receive(:breakdown_param).and_return(:all)
      @header_data = subject.header_data
    end

    it 'should have a param value for each data type' do
      params = scorecard_fields.map { |el| el[:data_type] }
      expect(@header_data.map { |el| el[:param] }).to eq(params)
    end

    it 'should translate the data_type fields' do
      translated_data_types = scorecard_fields.map do |el|
        I18n.t(el[:data_type], scope: subject.send(:collection_t_scope))
      end
      expect(@header_data.map { |el| el[:data_type] }).to eq(translated_data_types)
    end

    it 'should not set state average for school_info' do
      school_info_header = @header_data.find { |hd| hd[:param].to_s == 'school_info' }
      expect(school_info_header[:state_average]).to be_nil
    end

    it 'should set state average if there is one' do
      state_average_field = scorecard_fields.find { |f| !f[:state_average].nil? }
      state_average = state_average_field[:state_average][:all]
      state_average_param = state_average_field[:data_type].to_s
      state_average_header = @header_data.find do |hd|
        hd[:param].to_s == state_average_param
      end
      state_average_text = I18n.t(:state_average, val: state_average, scope: subject.send(:t_scope))
      expect(state_average_header[:state_average]).to eq(state_average_text)
    end

    it 'should say there is no state average if there is not one' do
      state_averageless_field = scorecard_fields.find do |f|
        f[:state_average].nil? && f[:data_type] != :school_info
      end
      state_averageless_param = state_averageless_field[:data_type].to_s
      state_averageless_header = @header_data.find do |hd|
        hd[:param].to_s == state_averageless_param
      end
      state_averageless_text = I18n.t(:state_average_not_available, scope: subject.send(:t_scope))
      expect(state_averageless_header[:state_average]).to eq(state_averageless_text)
    end
  end
end
