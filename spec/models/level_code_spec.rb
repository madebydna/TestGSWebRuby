require 'spec_helper'

describe LevelCode do

  describe '.from_grade' do
    inputs_and_outputs = {
      'PK' => LevelCode.new('p'),
      'KG' => LevelCode.new('e'),
      '1' => LevelCode.new('e'),
      '2' => LevelCode.new('e'),
      '3' => LevelCode.new('e'),
      '4' => LevelCode.new('e'),
      '5' => LevelCode.new('e'),
      '6' => LevelCode.new('m'),
      '7' => LevelCode.new('m'),
      '8' => LevelCode.new('m'),
      '9' => LevelCode.new('h'),
      '10' => LevelCode.new('h'),
      '11' => LevelCode.new('h'),
      '12' => LevelCode.new('h'),
      '13' => LevelCode.new('h'),
      'UG' => nil,
      'AE' => nil
    }

    inputs_and_outputs.each_pair do |grade, level_code|
      it "given grade #{grade} it should return level code #{level_code}" do
        expect(LevelCode.from_level(grade)).to eq(level_code)
      end
    end

  end

end