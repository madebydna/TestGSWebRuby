require_relative "../test_processor"
GS::ETL::Logging.disable

class NCTestProcessor2016EOCEOG < GS::ETL::TestProcessor

	def initialize(*args)
		super
		@year=2016
	end

	map_subject = {
		'M1' => 5,
		'RD' => 2,
		'MA' => 5,
		'E2' => 27,
    'BI' => 29,
    'SC' => 25
	}


	map_breakdown = {
		'ALL' => 1,
		'ASIA' => 2,
		'BLCK' => 3,
		'FEM' => 11,
		'EDS' => 9,
		'HISP' => 6,
		'LEP' => 15,
    'NOT_LEP' => 16,
		'MALE' => 12,
		'AMIN' => 4,
		'NOT_EDS' => 10,
		'PACI' => 112,
		'SWD' => 13,
    'NOT_SWD' => 14,
		'WHTE' => 8,
    'MULT' => 21
	}

  map_prof_bands = {
    :pct_l1 => 115,
    :pct_l2 => 116,
    :pct_l3 => 117,
    :pct_l4 => 118,
    :pct_l5 => 119,
    :null => 'null'
  }


 source('xaa.txt',[],col_sep:"\t")  do |s|
   s.transform("setting entity level", WithBlock) do |row|
     if row[:school_code] == 'NC-SEA'
       row[:entity_level] = 'state'
     elsif row[:school_code] =~ /^[0-9]{3}(LEA)$/
       row [:entity_level] = 'district'
       row[:district_name] = row[:name]
     else row[:entity_level] = 'school'
       row[:school_name] = row[:name]
     end
     row
   end
   .transform("Fill Columns",Fill,
     {
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
     })
   .transform("",MultiFieldRenamer,
     {
       school_code: :state_id,
       subgroup: :breakdown,
       grade: :grade,
       subject: :subject,
       num_tested: :number_tested
     })
   .transform('', WithBlock) do |row|
     row[:state_id] = row[:state_id].gsub('LEA','')
     row
   end
   .transform('delete unwanted test type rows', DeleteRows, :type, 'RG')
   .transform('delete unwanted test type rows', DeleteRows, :type, 'X1')
   .transform('delete unwanted subject rows', DeleteRows, :subject, 'ALL')
   .transform('delete unwanted subject rows', DeleteRows, :subject, 'EOC')
   .transform('delete unwanted subject rows', DeleteRows, :subject, 'EOG')
   .transform('delete unwanted subject rows', DeleteRows, :state_id, 'NC-SB1')
   .transform('delete unwanted subject rows', DeleteRows, :state_id, 'NC-SB2')
   .transform('delete unwanted subject rows', DeleteRows, :state_id, 'NC-SB3')
   .transform('delete unwanted subject rows', DeleteRows, :state_id, 'NC-SB4')
   .transform('delete unwanted subject rows', DeleteRows, :state_id, 'NC-SB5')
   .transform('delete unwanted subject rows', DeleteRows, :state_id, 'NC-SB6')
   .transform('delete unwanted subject rows', DeleteRows, :state_id, 'NC-SB7')
   .transform('delete unwanted subject rows', DeleteRows, :state_id, 'NC-SB8')
   .transform("removing comp subgroup rows", WithBlock) do |row|
     if row[:breakdown] =~ /^(MALE_)[a-zA-Z]+$/
       row[:breakdown] = 'skip'
     elsif row[:breakdown] =~ /^(FEM_)[a-zA-Z]+$/
       row[:breakdown] = 'skip'
     elsif row[:breakdown] =~ /^(AIG)\S*$/
       row[:breakdown] = 'skip'
     else row[:breakdown] = row[:breakdown]
     end
     row
   end
   .transform('setting grade all for eoc', WithBlock) do |row|
     if row[:grade] == 'EOC'
       row[:grade] = 'All'
     elsif row[:grade] =='GS'
       row[:grade] = 'All'
     else row[:grade] = row[:grade].gsub('0','')
     end
     row
   end
   .transform('', WithBlock) do |row|
     if row[:subject] == 'MA' || row[:subject] == 'SC' || row[:subject] == 'RD'
       row[:test_data_type] = 'EOG'
       row[:test_data_type_id] = 35
     else row[:test_data_type] = 'EOC'
       row[:test_data_type_id] = 34
     end
     row
   end
   .transform('', WithBlock) do |row|
     if row[:pct_l1] == '<5' || row[:pct_l1] == '>95' || row[:pct_l2] == '<5' || row[:pct_l2] == '>95' || row[:pct_l3] == '<5' || row[:pct_l3] == '>95' || row[:pct_l4] == '<5' || row[:pct_l4] == '>95' || row[:pct_l5] == '<5' || row[:pct_l5] == '>95'
       row[:breakdown] = 'skip'
     end
     row
   end
   .transform('delete n tested 10', DeleteRows, :number_tested, '10')
   .transform('delete unwanted breakdowns', DeleteRows, :breakdown, 'skip')
   .transform('mapping breakdowns', HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
   .transform('mapping subjects', HashLookup, :subject, map_subject, to: :subject_id)
   .transform('creating null prof band', SumValues, :null, :pct_l3, :pct_l4, :pct_l5)
   .transform('transposing prof columns', Transposer, :proficiency_band, :value_float, :pct_l1, :pct_l2, :pct_l3, :pct_l4, :pct_l5, :null)
   .transform('mapping proficiency band ids', HashLookup, :proficiency_band, map_prof_bands, to: :proficiency_band_id)
 end




	def config_hash
		{
			source_id: 22,
			state:'nc',
			notes:'DXT-1918 NC EOC EOG 2016',
			url: 'http://www.dpi.state.nc.us/',
			file: 'nc/2016/nc.2016.1.public.charter.[level].txt',
			level: nil,
			school_type: 'public,charter'
		}
	end
end

NCTestProcessor2016EOCEOG.new(ARGV[0],max:nil,offset:nil).run
