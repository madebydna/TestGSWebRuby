require 'spec_helper'

describe CharacteristicsCaching::CharacteristicsCacher do
  let(:school) { FactoryGirl.build(:alameda_high_school) }
  let(:cacher) { CharacteristicsCaching::CharacteristicsCacher.new(school) }

  describe '#build_hash_for_data_set' do

    let(:result) {
      Hashie::Mash.new({
                           data_type_id: 1,
                           characteristic_label: 'Planet of origin',
                           characteristic_source: 'Jupiter Dept of Ed',
                           level_code: 'h',
                           subject: 'no_subject_provided',
                           grade: 2,
                           year: 2010,
                           school_value: 10,
                           state_value: 20,
                           breakdown_name: 'Earthling'
                       })
    }

    it 'builds the correct hash' do
      expected = {
          'Planet of origin' => {
              2010 => {
                  grades: {
                      2 => {
                          'Jupiter Dept of Ed' => {
                              'Earthling' => {
                                  'h' => {
                                      'no_subject_provided' => {
                                          value: 10,
                                          state_average: 20
                                      }
                                  }
                              }
                          }
                      }
                  }
              }
          }
      }

      expect(cacher.build_hash_for_data_set(result)).to eq(expected)
    end
  end

end

