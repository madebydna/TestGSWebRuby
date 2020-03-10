require_relative "../test_processor"

class NHTestProcessor20172018Grade11ScienceSBAC < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2018
  end

  breakdown_id_map = {
      "All                                               " => 1,
      "All students             " => 1,
      "Race_Black_AfrAmerican                            " => 17,
      "Black                    " => 17,
      "Race_AmerInd_AlaskanNat                           " => 18,
      "Am. Indian               " => 18,
      "Race_Asian                                        " => 16,
      "Race_White                                        " => 21,
      "White                    " => 21,
      "Race_Hispanic                                     " => 19,
      "Hispanic                 " => 19,
      "Race_Two_or_More                                  " => 22,
      "Two or More races        " => 22,
      "Gender_Female                                     " => 26,
      "Female                   " => 26,
      "Gender_Male                                       " => 25,
      "Male                     " => 25,
      "EL_Current                                        " => 32,
      "EL - Current             " => 32,
      "EL_NotEL                                          " => 33,
      "Econdis                                           " => 23,
      "SES                      " => 23,
      "Econddis_NotEcondis                               " => 24,
      "IEP                                               " => 27,
      "IEP/SWD                  " => 27,
      "IEP_NotIEP                                        " => 30,
      "Race_Hawaiian                                     " => 41,
      "Asian+PI+Hawaiian        " => 15
  }

  subject_id_map = {
    "rea" => 2,
    "mat" => 5,
    "sci" => 19
  }

  proficiency_band_id_map = {
    percent_at_level_1: 5,
    percent_at_level_2: 6,
    percent_at_level_3: 7,
    percent_at_level_4: 8,
    prof_above: 1
  }

  source("nh_2018.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2018,
      date_valid: '2018-01-01 00:00:00',
      proficiency_band: :prof_above,
      description: 'In 2017-2018, the state of New Hampshire administered the NH Statewide Assessment System (NHSAS) to students in grades 3-8 for English Language Arts and mathematics, and in grades 5, 8, and 11 in science. The NHSAS is a standards-based, computer adaptive test aligned to the NH Academic Standards.'
    })
    .transform('Rename column headers', MultiFieldRenamer,{
      replevel: :level,
      subgroup: :breakdown,
      discode: :district_code,
      schcode: :school_code,
      disname: :district_name,
      schname: :school_name,
      paboveprof: :prof_above
    })
    .transform('Fill missing default fields', Fill, {
      test_data_type: 'NH SBAC',
      test_data_type_id: 249,
      notes: 'DXT-3132: NH SBAC'
    })
    .transform("filter out breakdowns",DeleteRows, :breakdown, 'EL - Curr + Monitor Yr1-4', 'Migrant                  ', 'Homeless                 ', 'Foster                   ')
    .transform("filter to Regular denominator",DeleteRows, :denominatortype, '95Percent')
    .transform("filter out suppressed rows",DeleteRows, :prof_above, '* n < 11')
    .transform("fix <10 >90 values",WithBlock) do |row|
      if row[:prof_above] == '<10' || row[:prof_above] == '>90'
        if row[:plevel3] != '<10' && row[:plevel3] != '>90' && row[:plevel4] != '<10' && row[:plevel4] != '>90'
          row[:prof_above] = row[:plevel3].to_f + row[:plevel4].to_f
        elsif row[:plevel1] != '<10' && row[:plevel1] != '>90' && row[:plevel2] != '<10' && row[:plevel2] != '>90'
          row[:prof_above] = 100 - row[:plevel1].to_f - row[:plevel2].to_f
          if row[:prof_above] == -1
            row[:prof_above] = 0
          end
        else row[:prof_above] = 'skip'
        end
      end
      row
    end
    .transform('Rename column headers', MultiFieldRenamer,{
      prof_above: :value
    })
    .transform("delete unfound values",DeleteRows, :value, 'skip')
    .transform("Assign entity type", WithBlock) do |row|
      if row[:level] == 'sch'
        row[:entity_type] = 'school'
      elsif row[:level] == 'dis'
        row[:entity_type] = 'district'
      elsif row[:level] == 'sta'
        row[:entity_type] = 'state'
      end
      row
    end
    .transform("fixing grade 0", WithBlock) do |row|
      row[:grade] = 'skip' unless row[:grade] == '11' && row[:subject] == 'sci'
      row
    end
    .transform("skip not grade 11",DeleteRows, :grade, 'skip')
    .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id)
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id)
    .transform("Map proficiency_band_id", HashLookup, :proficiency_band, proficiency_band_id_map, to: :proficiency_band_id)
    .transform('Set up state_id',WithBlock) do |row|
      if row[:entity_type] == 'school'
        row[:state_id] = row[:district_code].rjust(3,'0') + row[:school_code]
      elsif row[:entity_type] == 'district'
        row[:state_id] = row[:district_code].rjust(3,'0')
      else
        row[:state_id] = 'state'
      end
      row
    end
  end

    # .transform("byebug",WithBlock) do |row|
    #   require 'byebug'
    #   byebug
    # end


  def config_hash
    {
        source_id: 33,
        state: 'nh'
    }
  end
end

NHTestProcessor20172018Grade11ScienceSBAC.new(ARGV[0], max: nil).run