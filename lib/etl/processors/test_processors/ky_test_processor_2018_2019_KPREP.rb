require_relative "../../test_processor"


class KYTestProcessor20182019KPREP < GS::ETL::TestProcessor

	def initialize(*args)
		super
		@year=2019
    @ticket_n = 'DXT-3430'
	end


  map_subject = {
    'SC' => 19,
    'MA' => 5,
    'RD' => 2,
    'SS' => 18,
    'WR' => 3
  }



  map_breakdown = {
    'TST' => 1, #All Students
    'ETA' => 16, #Asian
    'ETB' => 17, #African American
    'SXF' => 26, #Female
    'LUP' => 23, #Free/Reduced-Price Meals
    'LUN' => 24, #Non Economically Disadvantaged
    'ETH' => 19, #Hispanic
    'LEP' => 32, #English Learners
    'LEN' => 33, #Non english learners 
    'SXM' => 25, #Male
    'ETI' => 18, #American Indian or Alaska Native
    'ACD' => 27, #Disability-With IEP (Total)
    'ACO' => 30, #General Education
    'ETW' => 21, #White (Non-Hispanic)
    'ETO' => 22, #Two or more races
    'ETP' => 37 #Pacific Islander
  }


  map_proficiency_band = {
  'novice' => 134,
  'apprentice' => 135,
  'proficient' => 136,
  'distinguished' => 137,
  'proficient_distinguished' => 1
  }



  source('ky_2018_2019.txt',[],col_sep:"\t")

  shared do |s|
   s.transform("Fill Columns",Fill,
     { 
       data_type_id: 312,
       notes: 'DXT-3430: KY K-PREP'
     })
   .transform('mapping breakdowns', HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
   .transform('mapping subjects', HashLookup, :subject, map_subject, to: :subject_id)
   .transform('mapping prof bands', HashLookup, :proficiency_band, map_proficiency_band, to: :proficiency_band_id)
   .transform('Assign descriptions and date_valid', WithBlock,) do |row|
        if [:year] == '2018'
            row[:description] = 'In 2017-2018, Kentucky used the Kentucky Performance Rating for Educational Progress (K-PREP) tests to assess students in grades 3 through 8 in reading and mathematics, grades 4, 7, and 11 in science, grades 5 and 8 in social studies, and grades 5, 8, and 11 in writing. The K-PREP is a standards-based test, which means it measures how well students are mastering specific skills defined for each grade by the state of Kentucky.'
            row[:date_valid] = '2018-01-01 00:00:00'
        elsif row[:year] == '2019'
            row[:description] = 'In 2018-2019, Kentucky used the Kentucky Performance Rating for Educational Progress (K-PREP) tests to assess students in grades 3 through 8, and 11 in reading and mathematics, grades 4, 7, and 11 in science, grades 5 and 8 in social studies, and grades 5, 8, and 11 in writing. The K-PREP is a standards-based test, which means it measures how well students are mastering specific skills defined for each grade by the state of Kentucky.'
            row[:date_valid] = '2019-01-01 00:00:00'
        end
        row
   end
  end


  def config_hash
    {
      source_id: 21, 
      state:'ky'
    }
  end
end

KYTestProcessor20182019KPREP.new(ARGV[0],max:nil,offset:nil).run
