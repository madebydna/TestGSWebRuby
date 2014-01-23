require 'spec_helper'

describe School do

  describe '.process_level' do

    it 'should return nil if levels array is empty'
      school = FactoryGirl.build(:school, level: [])
      expect school.to is nil
    end

    it 'should transform the input level array correctly into a formatted string connected levels'
      school = FactoryGirl.build(:school, level: ['PK','KG'])
      expect school.to eq 'PK-K'
    end

    it 'should transform the input level array correctly into a formatted string connected levels extended version'
      school = FactoryGirl.build(:school, level: ['PK','KG','1','2','3','4','5'])
      expect school.to eq 'PK-5'
    end

    it 'should transform the input level array correctly into a formatted string connected levels 3 with Ungraded appended'
      school = FactoryGirl.build(:school, level: ['PK','KG','1','2','3','4','5','UG'])
      expect school.to eq 'PK-5 & Ungraded'
    end

    it 'should transform the input level array correctly into a formatted string with connected levels and commas between series or instances'
      school = FactoryGirl.build(:school, level: ['PK','KG','1','3','4','5'])
      expect school.to eq 'PK-1, 3-5'
    end

    it 'should transform the input level array with no series to levels separated by comma/s'
      school = FactoryGirl.build(:school, level: ['7','11'])
      expect school.to eq '7, 11'
    end

    it 'should transform KG into K'
      school = FactoryGirl.build(:school, level: ['KG'])
      expect school.to eq 'K'
    end

    it 'should transform UG into Ungraded'
      school = FactoryGirl.build(:school, level: ['UG'])
      expect school.to eq 'Ungraded'
    end

    it 'should transform an individual grade that is not a special case'
      school = FactoryGirl.build(:school, level: ['10'])
      expect school.to eq '10'
    end

    it 'should transform the input array "level" to a mix of series and gaps'
      school = FactoryGirl.build(:school, level: ['PK','1','2','3','6','9','10','11','12'])
      expect school.to eq 'PK, 1-3, 6, 9-12'
    end
  end
end