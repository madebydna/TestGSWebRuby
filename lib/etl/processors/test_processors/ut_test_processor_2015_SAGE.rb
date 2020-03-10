require_relative "../test_processor"
GS::ETL::Logging.disable

class UTTestProcessor2015SAGE < GS::ETL::TestProcessor

   def initialize(*args)
      super
      @year = 2015
   end

 source("UT_district_subgroups_NoEOC.txt",[],col_sep: "\t") do |s|
      s.transform('fill', Fill,{
      entity_level: 'district'
      })
      .transform('subject',MultiFieldRenamer, subjectarea: :subject)
 end 	
 source("UT_school_overall.txt",[],col_sep: "\t") do |s|
     s.transform("breakdown",Fill,{   
        breakdown: 'All Students',
       entity_level: 'school'
    })
end
 source('UT_district_overall_EOC_2014.txt',[],col_sep: "\t") do |s|
        s.transform('fill',Fill,{
        entity_level: 'district',
        breakdown: 'All Students',
	grade: 'All'
        })
 end  
 source('UT_district_overall_EOC_2015.txt',[],col_sep: "\t") do |s|
        s.transform('fill',Fill,{
        entity_level: 'district',
        breakdown: 'All Students',
	grade: 'All'
        })
 end
 source("UT_school_subgroups.txt",[],col_sep: "\t") do |s|
     s.transform("breakdown",Fill,{
       entity_level: 'school',
     })
 end  
 source('UT_district_overall_NoEOC.txt',[],col_sep: "\t") do |s|
        s.transform('fill',Fill,{
        entity_level: 'district',
        breakdown: 'All Students'
        })
	.transform('subject',MultiFieldRenamer,subjectarea: :subject)
 end
  source("UT_state_subgroups_NoEOC.txt",[],col_sep: "\t") do |s|
      s.transform("breakdown",Fill,{
	 entity_level: 'state',
      })
      .transform('subject',MultiFieldRenamer,subjectarea: :subject)
  end  
  source("UT_state_overall_EOC_2014.txt",[],col_sep: "\t") do |s|
      s.transform("breakdown",Fill,{
	 entity_level: 'state',
	 breakdown: 'All Students',
	 grade: 'All'
      })
  end 
  source("UT_state_overall_EOC_2015.txt",[],col_sep: "\t") do |s|
      s.transform("breakdown",Fill,{
	 entity_level: 'state',
	 breakdown: 'All Students',
	 grade: 'All'
      })
  end  
  source("UT_state_overall_NoEOC.txt",[],col_sep: "\t") do |s|
      s.transform("breakdown",Fill,{
	 entity_level: 'state',
	 breakdown: 'All Students'
      })
      .transform('subject',MultiFieldRenamer,subjectarea: :subject)
  end  

   map_breakdown_id = { 
	'Income - F&RL' => 9,
	'Income - Not F&RL' => 10,
	'Race - Black' => 3,
	'Race - Hispanic/Latino' => 6,
	'Race - Multiple Races' => 21,
	'Race - White' => 8,
	'Sex - Female' => 11,
	'Sex - Male' => 12,
	'Race - Pacific Islander' => 7,
	'Race - American Indian' => 4,
	'All Students' => 1,	
	'Race - Asian' => 2,
   }

   map_prof_band_id = {
     percentproficient: 'null',
     percent_proficient: 'null'
   }

   map_subject_id = {
   	'Language Arts' => 4,
	'L' => 4,
	'M' => 5,
	'Math' => 5,
	'S' => 25,
	'Secondary Math I' => 91,
	'Secondary Math II' => 92,
	'Secondary Math III' => 93,
	'Earth Science' => 43,
	'Biology' => 29,
	'Chemistry' => 42,
	'Physics' => 41,
	'Science' => 25,
   }
   

   shared do |s|
     s.transform("Rename columns", MultiFieldRenamer,
      {
      district_nbr: :district_id,
      school_nbr: :school_id,
      schoolyear: :year,
      demographic: :breakdown,
      districtlea: :district_name,
      gradelevel: :grade,
      subjectarea: :subject,
      school_year: :year,
      percent_proficient: :percentproficient,
      })
     .transform('',WithBlock,) do |row|
	     #require 'byebug'
	     #byebug
	     row
     end
     .transform('delete 2016 data',DeleteRows,:year, '2016')
     .transform('duplicat school',DeleteRows,:school_name, 'WILLOW SPRINGS SCHOOL')
     .transform("delete rows where subject contains special ed",DeleteRows, :subject, /^Special Ed/)
     .transform("delete rows where subject contains special ed",DeleteRows, :testname, /^Special Ed/)
     .transform('delete rows where school id contains a letter',DeleteRows, :school_id, /[A-Za-z]/)
     .transform('delete rows where n<10',DeleteRows,:percentproficient, 'N < 10')
     .transform('delete percent >20',DeleteRows,:percentproficient, '> 80%')
     .transform('delete percent >20',DeleteRows,:percentproficient, '< 20%')
     .transform('delete rows where n<10',DeleteRows,:percentproficient, 'N?10')
     .transform('delete percent >20',DeleteRows,:percentproficient, '?80%')
     .transform('delete percent >20',DeleteRows,:percentproficient, '?20%')
     .transform("Add column with breakdown id", HashLookup, :breakdown, map_breakdown_id, to: :breakdown_id)
     .transform("state_id column", WithBlock,) do |row|
	     if row[:entity_level] == 'district' && row[:district_id] !~ /[A-Za-z]/
		     row[:state_id] = '%02d' % (row[:district_id])
	     elsif row[:entity_level] == 'district' && row[:district_id] =~ /[A-Za-z]/
		     row[:state_id] = row[:district_id]
	     elsif row[:entity_level] == 'school' && row[:district_id] !~ /[A-Za-z]/ && row[:school_id] !~ /[A-Za-z]/
		     row[:state_id] = "%02d%03d" % [row[:district_id],row[:school_id]]
	     elsif row[:entity_level] == 'school' && row[:district_id] =~ /[A-Za-z]/  && row[:school_id] !~ /[A-Za-z]/
	     	     row[:state_id] = row[:district_id]<<'%03d' % (row[:school_id])
	     elsif row[:entity_level] == 'state'
		     row[:state_id] = 'state'
	     end
	     row
     end
    .transform('grade level and subject',WithBlock,) do |row|
	    if row[:entity_level] == 'school'
	     if row[:testname] =~ /Grade/
		    row[:grade] = row[:testname].split(' Grade ').first
		    row[:subject] = row[:testname].split(' Grade ').last
		    row[:grade] = row[:grade].gsub(/[^0-9]/,'')
		    #row[:grade] = "%02i" % (row[:grade])
	     else
		    row[:grade] = 'All'
		   row[:subject] = row[:testname]
	     end
	    end
	    #row[:grade] = row[:grade].sub!(/^0/,'')
	    row
     end
   .transform('school state id with 2 schools',DeleteRows,:state_id, '42407') 
     .transform("transpose prof bands", Transposer, :proficiency_band, :value_float,:percentproficient )
     .transform("map prof band id",HashLookup, :proficiency_band, map_prof_band_id, to: :proficiency_band_id) 
     .transform('map subject id',HashLookup,:subject, map_subject_id, to: :subject_id)
     .transform('ranges',WithBlock,) do |row|
	     row[:value_float] = row[:value_float].tr('%','')
	     if row[:value_float] =~ /-/
		     low = (row[:value_float].split('-').first).to_f
		     high = (row[:value_float].split('-').last).to_f
		     row[:value_float] = ((low+high).to_f / 2.00).ceil
	     end
	     row[:value_float] = (row[:value_float].to_s).tr('?','-')
	     row[:value_float] = (row[:value_float]).tr('<','-')
	     row[:value_float] = (row[:value_float]).tr('>','-')
	     row[:value_float] = (row[:value_float]).gsub('- ','-')
	     row
     end
     .transform("Fill in year, entity type, level code, test data type and id", Fill, {
	 entity_type: 'public,charter',
	 test_data_type: 'SAGE',
	 test_data_type_id: 315,
	 level_code: 'e,m,h',
	 number_tested: nil,
      }) 
      .transform('check',WithBlock,) do |row|
	    #require 'byebug'
	    #byebug
	    row
     end 
   end

   def config_hash
   {
       source_id: 68,
       state: 'ut',
       notes: 'DXT-1555 UT 2014, 2015 SAGE',
       url: 'http://www.usoe.k12.ut.us/',
       file: 'ut/DXT-1555/ut.2015.1.public.charter.[level].txt',
       level: nil,
       school_type: 'public,charter'
   } 
   end

end

UTTestProcessor2015SAGE.new(ARGV[0],max:nil,offset:nil).run
