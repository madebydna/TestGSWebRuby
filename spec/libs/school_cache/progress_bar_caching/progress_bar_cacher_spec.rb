require 'spec_helper'
describe ProgressBarCaching::ProgressBarCacher do
  let(:school) { FactoryGirl.build(:alameda_high_school) }
  let(:cacher) { ProgressBarCaching::ProgressBarCacher.new(school) }

  describe '#osp_data_present' do
    it 'should return false if no data present' do
      allow(cacher).to receive(:osp_data).and_return(nil)
      expect(cacher.osp_data_present?).to be_falsey
    end

    it 'should return false if only a few keys are present' do
      allow(cacher).to receive(:osp_data).and_return(few_osp_data)
      expect(cacher.osp_data_present?).to be_falsey
    end

    it 'should return true if all keys are present' do
      allow(cacher).to receive(:osp_data).and_return(all_osp_data)
      expect(cacher.osp_data_present?).to be_truthy
    end

  end

  let(:few_osp_data) { [FactoryGirl.build(  :esp_response,
                                            response_key: 'arts_visual',
                                            response_value: 'value',
                                            school: school
                        ),
                        FactoryGirl.build(  :esp_response,
                                            response_key: 'foreign_language',
                                            response_value: 'value',
                                            school: school
                        ),

                        FactoryGirl.build(  :esp_response,
                                            response_key: 'boys_sports',
                                            response_value: 'value',
                                            school: school
                        )]}

  let(:all_osp_data) { [FactoryGirl.build(  :esp_response,
                                            response_key: 'arts_visual',
                                            response_value: 'value',
                                            school: school
                        ),
                        FactoryGirl.build(  :esp_response,
                                            response_key: 'foreign_language',
                                            response_value: 'value',
                                            school: school
                        ),
                        FactoryGirl.build(  :esp_response,
                                            response_key: 'before_after_care',
                                            response_value: 'value',
                                            school: school
                        ),
                        FactoryGirl.build(  :esp_response,
                                            response_key: 'transportation_other',
                                            response_value: 'value',
                                            school: school
                        ),
                        FactoryGirl.build(  :esp_response,
                                            response_key: 'girls_sports_other',
                                            response_value: 'value',
                                            school: school
                        ),
                        FactoryGirl.build(  :esp_response,
                                            response_key: 'boys_sports',
                                            response_value: 'value',
                                            school: school
                        ),
                        FactoryGirl.build(  :esp_response,
                                            response_key: 'staff_resources',
                                            response_value: 'value',
                                            school: school
                        ),
                        FactoryGirl.build(  :esp_response,
                                            response_key: 'parent_involvement_other',
                                            response_value: 'value',
                                            school: school
                        ),
                        FactoryGirl.build(  :esp_response,
                                            response_key: 'facilities',
                                            response_value: 'value',
                                            school: school
                        )]}


end