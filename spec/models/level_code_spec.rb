require 'spec_helper'

describe LevelCode do

  describe '.from_grade' do
    inputs_and_outputs = {
      'PK' => LevelCode.new('p'),
      'KG' => LevelCode.new('e'),
      'P' => LevelCode.new('p'),
      'K' => LevelCode.new('e'),
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
        expect(LevelCode.from_grade(grade)).to eq(level_code)
      end
    end

  end

  describe '.full_from_grade' do
    it 'should return nil if a string is not recieved' do

    end


    {
      'PK' => 'Preschool',
      'KG' => 'Elementary',
      'P' => 'Preschool',
      'K' => 'Elementary',
      '1' => 'Elementary',
      '2' => 'Elementary',
      '3' => 'Elementary',
      '4' => 'Elementary',
      '5' => 'Elementary',
      '6' => 'Middle',
      '7' => 'Middle',
      '8' => 'Middle',
      '9' => 'High',
      '10' => 'High',
      '11' => 'High',
      '12' => 'High',
      '13' => 'High',
    }.each do | grade, level_code |
      it "should return #{level_code} if #{grade} is passed in" do
        expect(LevelCode.full_from_grade(grade)).to eql(level_code)
      end
    end
  end

end
