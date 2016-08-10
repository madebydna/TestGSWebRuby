require_relative "../test_processor"

class INTestProcessor2015ISTEPSubgroups < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2015
  end

  source("in_2015_subgroup_english_ethnicity_combined_header.txt",[], col_sep: "\t") do |s|
    s.transform("Set entity_level to school", Fill, { entity_level: 'school' })
    .transform("Split district name from district id", WithBlock) do |row|
      split_row=row[:corporation_name_with_id].split(' - ')
      row[:district_id]=split_row[0]
      row[:district_name]=split_row[1]
      row
    end
    .transform("Split school name from school id", WithBlock) do |row|
      split_row=row[:school_name_with_id].split(' - ')
      row[:school_id]=split_row[0]
      row[:school_name]=split_row[1]
      row
    end
    .transform('Transpose value columns', Transposer,
       :grade_breakdown_subject,
       :value_float,
       :"3_american_indian_ela_pass_",
       :"3_black_ela_pass_",
       :"3_hispanic_ela_pass_",
       :"3_white_ela_pass_",
       :"3_multiracial_ela_pass_",
       :"3_native_hawaiian_or_other_pacific_islander_ela_pass_",
       :"3_asian_ela_pass_",
       :"4_unknown_ela_pass_",
       :"4_american_indian_ela_pass_",
       :"4_black_ela_pass_",
       :"4_hispanic_ela_pass_",
       :"4_white_ela_pass_",
       :"4_multiracial_ela_pass_",
       :"4_native_hawaiian_or_other_pacific_islander_ela_pass_",
       :"4_asian_ela_pass_",
       :"5_unknown_ela_pass_",
       :"5_american_indian_ela_pass_",
       :"5_black_ela_pass_",
       :"5_hispanic_ela_pass_",
       :"5_white_ela_pass_",
       :"5_multiracial_ela_pass_",
       :"5_native_hawaiian_or_other_pacific_islander_ela_pass_",
       :"5_asian_ela_pass_",
       :"6_unknown_ela_pass_",
       :"6_american_indian_ela_pass_",
       :"6_black_ela_pass_",
       :"6_hispanic_ela_pass_",
       :"6_white_ela_pass_",
       :"6_multiracial_ela_pass_",
       :"6_native_hawaiian_or_other_pacific_islander_ela_pass_",
       :"6_asian_ela_pass_",
       :"7_american_indian_ela_pass_",
       :"7_black_ela_pass_",
       :"7_hispanic_ela_pass_",
       :"7_white_ela_pass_",
       :"7_multiracial_ela_pass_",
       :"7_native_hawaiian_or_other_pacific_islander_ela_pass_",
       :"7_asian_ela_pass_",
       :"8_unknown_ela_pass_",
       :"8_american_indian_ela_pass_",
       :"8_black_ela_pass_",
       :"8_hispanic_ela_pass_",
       :"8_white_ela_pass_",
       :"8_multiracial_ela_pass_",
       :"8_native_hawaiian_or_other_pacific_islander_ela_pass_",
       :"8_asian_ela_pass_"
     )
  end

  source("in_2015_subgroup_english_gender_combined_header.txt",[], col_sep: "\t") do |s|
    s.transform("Set entity_level to school", Fill, { entity_level: 'school' })
    .transform("Split district name from district id", WithBlock) do |row|
      split_row=row[:corporation_name_with_id].split(' - ')
      row[:district_id]=split_row[0]
      row[:district_name]=split_row[1]
      row
    end
    .transform("Split school name from school id", WithBlock) do |row|
      split_row=row[:school_name_with_id].split(' - ')
      row[:school_id]=split_row[0]
      row[:school_name]=split_row[1]
      row
    end
    .transform('Transpose value columns', Transposer,
       :grade_breakdown_subject,
       :value_float,
       :"8_asian_ela_pass_",
       :"3_female_ela_pass_",
       :"3_male_ela_pass_",
       :"4_female_ela_pass_",
       :"4_male_ela_pass_",
       :"5_female_ela_pass_",
       :"5_male_ela_pass_",
       :"6_female_ela_pass_",
       :"6_male_ela_pass_",
       :"7_female_ela_pass_",
       :"7_male_ela_pass_",
       :"8_female_ela_pass_",
       :"8_male_ela_pass_"
     )

  end

  source("in_2015_subgroup_english_ses_combined_header.txt",[], col_sep: "\t") do |s|
    s.transform("Set entity_level to school", Fill, { entity_level: 'school' })
    .transform("Split district name from district id", WithBlock) do |row|
      split_row=row[:corporation_name_with_id].split(' - ')
      row[:district_id]=split_row[0]
      row[:district_name]=split_row[1]
      row
    end
    .transform("Split school name from school id", WithBlock) do |row|
      split_row=row[:school_name_with_id].split(' - ')
      row[:school_id]=split_row[0]
      row[:school_name]=split_row[1]
      row
    end
    .transform('Transpose value columns', Transposer,
       :grade_breakdown_subject,
       :value_float,
       :"3_paid_meals_ela_pass_",
       :"3_freereduced_price_meals_ela_pass_",
       :"4_paid_meals_ela_pass_",
       :"4_freereduced_price_meals_ela_pass_",
       :"5_paid_meals_ela_pass_",
       :"5_freereduced_price_meals_ela_pass_",
       :"6_paid_meals_ela_pass_",
       :"6_freereduced_price_meals_ela_pass_",
       :"7_paid_meals_ela_pass_",
       :"7_freereduced_price_meals_ela_pass_",
       :"8_paid_meals_ela_pass_",
       :"8_freereduced_price_meals_ela_pass_"
     )
  end

  source("in_2015_subgroup_math_ethnicity_combined_header.txt",[], col_sep: "\t") do |s|
    s.transform("Set entity_level to school", Fill, { entity_level: 'school' })
    .transform("Split district name from district id", WithBlock) do |row|
      split_row=row[:corporation_name_with_id].split(' - ')
      row[:district_id]=split_row[0]
      row[:district_name]=split_row[1]
      row
    end
    .transform("Split school name from school id", WithBlock) do |row|
      split_row=row[:school_name_with_id].split(' - ')
      row[:school_id]=split_row[0]
      row[:school_name]=split_row[1]
      row
    end
    .transform('Transpose value columns', Transposer,
       :grade_breakdown_subject,
       :value_float,
       :"3_american_indian_math_pass_",
       :"3_black_math_pass_",
       :"3_hispanic_math_pass_",
       :"3_white_math_pass_",
       :"3_multiracial_math_pass_",
       :"3_native_hawaiian_or_other_pacific_islander_math_pass_",
       :"3_asian_math_pass_",
       :"4_unknown_math_pass_",
       :"4_american_indian_math_pass_",
       :"4_black_math_pass_",
       :"4_hispanic_math_pass_",
       :"4_white_math_pass_",
       :"4_multiracial_math_pass_",
       :"4_native_hawaiian_or_other_pacific_islander_math_pass_",
       :"4_asian_math_pass_",
       :"5_unknown_math_pass_",
       :"5_american_indian_math_pass_",
       :"5_black_math_pass_",
       :"5_hispanic_math_pass_",
       :"5_white_math_pass_",
       :"5_multiracial_math_pass_",
       :"5_native_hawaiian_or_other_pacific_islander_math_pass_",
       :"5_asian_math_pass_",
       :"6_unknown_math_pass_",
       :"6_american_indian_math_pass_",
       :"6_black_math_pass_",
       :"6_hispanic_math_pass_",
       :"6_white_math_pass_",
       :"6_multiracial_math_pass_",
       :"6_native_hawaiian_or_other_pacific_islander_math_pass_",
       :"6_asian_math_pass_",
       :"7_american_indian_math_pass_",
       :"7_black_math_pass_",
       :"7_hispanic_math_pass_",
       :"7_white_math_pass_",
       :"7_multiracial_math_pass_",
       :"7_native_hawaiian_or_other_pacific_islander_math_pass_",
       :"7_asian_math_pass_",
       :"8_unknown_math_pass_",
       :"8_american_indian_math_pass_",
       :"8_black_math_pass_",
       :"8_hispanic_math_pass_",
       :"8_white_math_pass_",
       :"8_multiracial_math_pass_",
       :"8_native_hawaiian_or_other_pacific_islander_math_pass_",
       :"8_asian_math_pass_"
     )
  end

  source("in_2015_subgroup_math_gender_combined_header.txt",[], col_sep: "\t") do |s|
    s.transform("Set entity_level to school", Fill, { entity_level: 'school' })
    .transform("Split district name from district id", WithBlock) do |row|
      split_row=row[:corporation_name_with_id].split(' - ')
      row[:district_id]=split_row[0]
      row[:district_name]=split_row[1]
      row
    end
    .transform("Split school name from school id", WithBlock) do |row|
      split_row=row[:school_name_with_id].split(' - ')
      row[:school_id]=split_row[0]
      row[:school_name]=split_row[1]
      row
    end
    .transform('Transpose value columns', Transposer,
       :grade_breakdown_subject,
       :value_float,
       :"8_asian_math_pass_",
       :"3_female_math_pass_",
       :"3_male_math_pass_",
       :"4_female_math_pass_",
       :"4_male_math_pass_",
       :"5_female_math_pass_",
       :"5_male_math_pass_",
       :"6_female_math_pass_",
       :"6_male_math_pass_",
       :"7_female_math_pass_",
       :"7_male_math_pass_",
       :"8_female_math_pass_",
       :"8_male_math_pass_"
     )

  end

  source("in_2015_subgroup_math_ses_combined_header.txt",[], col_sep: "\t") do |s|
    s.transform("Set entity_level to school", Fill, { entity_level: 'school' })
    .transform("Split district name from district id", WithBlock) do |row|
      split_row=row[:corporation_name_with_id].split(' - ')
      row[:district_id]=split_row[0]
      row[:district_name]=split_row[1]
      row
    end
    .transform("Split school name from school id", WithBlock) do |row|
      split_row=row[:school_name_with_id].split(' - ')
      row[:school_id]=split_row[0]
      row[:school_name]=split_row[1]
      row
    end
    .transform('Transpose value columns', Transposer,
       :grade_breakdown_subject,
       :value_float,
       :"3_paid_meals_math_pass_",
       :"3_freereduced_price_meals_math_pass_",
       :"4_paid_meals_math_pass_",
       :"4_freereduced_price_meals_math_pass_",
       :"5_paid_meals_math_pass_",
       :"5_freereduced_price_meals_math_pass_",
       :"6_paid_meals_math_pass_",
       :"6_freereduced_price_meals_math_pass_",
       :"7_paid_meals_math_pass_",
       :"7_freereduced_price_meals_math_pass_",
       :"8_paid_meals_math_pass_",
       :"8_freereduced_price_meals_math_pass_"
     )
  end

  source("in_2015_subgroup_science_ethnicity_combined_header.txt",[], col_sep: "\t") do |s|
    s.transform("Set entity_level to school", Fill, { entity_level: 'school' })
    .transform("Split district name from district id", WithBlock) do |row|
      split_row=row[:corporation_name_with_id].split(' - ')
      row[:district_id]=split_row[0]
      row[:district_name]=split_row[1]
      row
    end
    .transform("Split school name from school id", WithBlock) do |row|
      split_row=row[:school_name_with_id].split(' - ')
      row[:school_id]=split_row[0]
      row[:school_name]=split_row[1]
      row
    end
    .transform('Transpose value columns', Transposer,
       :grade_breakdown_subject,
       :value_float,
       :"3_american_indian_science_pass_",
       :"3_black_science_pass_",
       :"3_hispanic_science_pass_",
       :"3_white_science_pass_",
       :"3_multiracial_science_pass_",
       :"3_native_hawaiian_or_other_pacific_islander_science_pass_",
       :"3_asian_science_pass_",
       :"4_unknown_science_pass_",
       :"4_american_indian_science_pass_",
       :"4_black_science_pass_",
       :"4_hispanic_science_pass_",
       :"4_white_science_pass_",
       :"4_multiracial_science_pass_",
       :"4_native_hawaiian_or_other_pacific_islander_science_pass_",
       :"4_asian_science_pass_",
       :"5_unknown_science_pass_",
       :"5_american_indian_science_pass_",
       :"5_black_science_pass_",
       :"5_hispanic_science_pass_",
       :"5_white_science_pass_",
       :"5_multiracial_science_pass_",
       :"5_native_hawaiian_or_other_pacific_islander_science_pass_",
       :"5_asian_science_pass_",
       :"6_unknown_science_pass_",
       :"6_american_indian_science_pass_",
       :"6_black_science_pass_",
       :"6_hispanic_science_pass_",
       :"6_white_science_pass_",
       :"6_multiracial_science_pass_",
       :"6_native_hawaiian_or_other_pacific_islander_science_pass_",
       :"6_asian_science_pass_",
       :"7_american_indian_science_pass_",
       :"7_black_science_pass_",
       :"7_hispanic_science_pass_",
       :"7_white_science_pass_",
       :"7_multiracial_science_pass_",
       :"7_native_hawaiian_or_other_pacific_islander_science_pass_",
       :"7_asian_science_pass_",
       :"8_unknown_science_pass_",
       :"8_american_indian_science_pass_",
       :"8_black_science_pass_",
       :"8_hispanic_science_pass_",
       :"8_white_science_pass_",
       :"8_multiracial_science_pass_",
       :"8_native_hawaiian_or_other_pacific_islander_science_pass_",
       :"8_asian_science_pass_"
     )
  end

  source("in_2015_subgroup_science_gender_combined_header.txt",[], col_sep: "\t") do |s|
    s.transform("Set entity_level to school", Fill, { entity_level: 'school' })
    .transform("Split district name from district id", WithBlock) do |row|
      split_row=row[:corporation_name_with_id].split(' - ')
      row[:district_id]=split_row[0]
      row[:district_name]=split_row[1]
      row
    end
    .transform("Split school name from school id", WithBlock) do |row|
      split_row=row[:school_name_with_id].split(' - ')
      row[:school_id]=split_row[0]
      row[:school_name]=split_row[1]
      row
    end
    .transform('Transpose value columns', Transposer,
       :grade_breakdown_subject,
       :value_float,
       :"8_asian_science_pass_",
       :"3_female_science_pass_",
       :"3_male_science_pass_",
       :"4_female_science_pass_",
       :"4_male_science_pass_",
       :"5_female_science_pass_",
       :"5_male_science_pass_",
       :"6_female_science_pass_",
       :"6_male_science_pass_",
       :"7_female_science_pass_",
       :"7_male_science_pass_",
       :"8_female_science_pass_",
       :"8_male_science_pass_"
     )

  end

  source("in_2015_subgroup_science_ses_combined_header.txt",[], col_sep: "\t") do |s|
    s.transform("Set entity_level to school", Fill, { entity_level: 'school' })
    .transform("Split district name from district id", WithBlock) do |row|
      split_row=row[:corporation_name_with_id].split(' - ')
      row[:district_id]=split_row[0]
      row[:district_name]=split_row[1]
      row
    end
    .transform("Split school name from school id", WithBlock) do |row|
      split_row=row[:school_name_with_id].split(' - ')
      row[:school_id]=split_row[0]
      row[:school_name]=split_row[1]
      row
    end
    .transform('Transpose value columns', Transposer,
       :grade_breakdown_subject,
       :value_float,
       :"3_paid_meals_science_pass_",
       :"3_freereduced_price_meals_science_pass_",
       :"4_paid_meals_science_pass_",
       :"4_freereduced_price_meals_science_pass_",
       :"5_paid_meals_science_pass_",
       :"5_freereduced_price_meals_science_pass_",
       :"6_paid_meals_science_pass_",
       :"6_freereduced_price_meals_science_pass_",
       :"7_paid_meals_science_pass_",
       :"7_freereduced_price_meals_science_pass_",
       :"8_paid_meals_science_pass_",
       :"8_freereduced_price_meals_science_pass_"
     )
  end

  source("in_2015_subgroup_social_studies_ethnicity_combined_header.txt",[], col_sep: "\t") do |s|
    s.transform("Set entity_level to school", Fill, { entity_level: 'school' })
    .transform("Split district name from district id", WithBlock) do |row|
      split_row=row[:corporation_name_with_id].split(' - ')
      row[:district_id]=split_row[0]
      row[:district_name]=split_row[1]
      row
    end
    .transform("Split school name from school id", WithBlock) do |row|
      split_row=row[:school_name_with_id].split(' - ')
      row[:school_id]=split_row[0]
      row[:school_name]=split_row[1]
      row
    end
    .transform('Transpose value columns', Transposer,
       :grade_breakdown_subject,
       :value_float,
       :"3_american_indian_social_studies_pass_",
       :"3_black_social_studies_pass_",
       :"3_hispanic_social_studies_pass_",
       :"3_white_social_studies_pass_",
       :"3_multiracial_social_studies_pass_",
       :"3_native_hawaiian_or_other_pacific_islander_social_studies_pass_",
       :"3_asian_social_studies_pass_",
       :"4_unknown_social_studies_pass_",
       :"4_american_indian_social_studies_pass_",
       :"4_black_social_studies_pass_",
       :"4_hispanic_social_studies_pass_",
       :"4_white_social_studies_pass_",
       :"4_multiracial_social_studies_pass_",
       :"4_native_hawaiian_or_other_pacific_islander_social_studies_pass_",
       :"4_asian_social_studies_pass_",
       :"5_unknown_social_studies_pass_",
       :"5_american_indian_social_studies_pass_",
       :"5_black_social_studies_pass_",
       :"5_hispanic_social_studies_pass_",
       :"5_white_social_studies_pass_",
       :"5_multiracial_social_studies_pass_",
       :"5_native_hawaiian_or_other_pacific_islander_social_studies_pass_",
       :"5_asian_social_studies_pass_",
       :"6_unknown_social_studies_pass_",
       :"6_american_indian_social_studies_pass_",
       :"6_black_social_studies_pass_",
       :"6_hispanic_social_studies_pass_",
       :"6_white_social_studies_pass_",
       :"6_multiracial_social_studies_pass_",
       :"6_native_hawaiian_or_other_pacific_islander_social_studies_pass_",
       :"6_asian_social_studies_pass_",
       :"7_american_indian_social_studies_pass_",
       :"7_black_social_studies_pass_",
       :"7_hispanic_social_studies_pass_",
       :"7_white_social_studies_pass_",
       :"7_multiracial_social_studies_pass_",
       :"7_native_hawaiian_or_other_pacific_islander_social_studies_pass_",
       :"7_asian_social_studies_pass_",
       :"8_unknown_social_studies_pass_",
       :"8_american_indian_social_studies_pass_",
       :"8_black_social_studies_pass_",
       :"8_hispanic_social_studies_pass_",
       :"8_white_social_studies_pass_",
       :"8_multiracial_social_studies_pass_",
       :"8_native_hawaiian_or_other_pacific_islander_social_studies_pass_",
       :"8_asian_social_studies_pass_"
     )
  end

  source("in_2015_subgroup_social_studies_gender_combined_header.txt",[], col_sep: "\t") do |s|
    s.transform("Set entity_level to school", Fill, { entity_level: 'school' })
    .transform("Split district name from district id", WithBlock) do |row|
      split_row=row[:corporation_name_with_id].split(' - ')
      row[:district_id]=split_row[0]
      row[:district_name]=split_row[1]
      row
    end
    .transform("Split school name from school id", WithBlock) do |row|
      split_row=row[:school_name_with_id].split(' - ')
      row[:school_id]=split_row[0]
      row[:school_name]=split_row[1]
      row
    end
    .transform('Transpose value columns', Transposer,
       :grade_breakdown_subject,
       :value_float,
       :"8_asian_social_studies_pass_",
       :"3_female_social_studies_pass_",
       :"3_male_social_studies_pass_",
       :"4_female_social_studies_pass_",
       :"4_male_social_studies_pass_",
       :"5_female_social_studies_pass_",
       :"5_male_social_studies_pass_",
       :"6_female_social_studies_pass_",
       :"6_male_social_studies_pass_",
       :"7_female_social_studies_pass_",
       :"7_male_social_studies_pass_",
       :"8_female_social_studies_pass_",
       :"8_male_social_studies_pass_"
     )

  end

  source("in_2015_subgroup_social_studies_ses_combined_header.txt",[], col_sep: "\t") do |s|
    s.transform("Set entity_level to school", Fill, { entity_level: 'school' })
    .transform("Split district name from district id", WithBlock) do |row|
      split_row=row[:corporation_name_with_id].split(' - ')
      row[:district_id]=split_row[0]
      row[:district_name]=split_row[1]
      row
    end
    .transform("Split school name from school id", WithBlock) do |row|
      split_row=row[:school_name_with_id].split(' - ')
      row[:school_id]=split_row[0]
      row[:school_name]=split_row[1]
      row
    end
    .transform('Transpose value columns', Transposer,
       :grade_breakdown_subject,
       :value_float,
       :"3_paid_meals_social_studies_pass_",
       :"3_freereduced_price_meals_social_studies_pass_",
       :"4_paid_meals_social_studies_pass_",
       :"4_freereduced_price_meals_social_studies_pass_",
       :"5_paid_meals_social_studies_pass_",
       :"5_freereduced_price_meals_social_studies_pass_",
       :"6_paid_meals_social_studies_pass_",
       :"6_freereduced_price_meals_social_studies_pass_",
       :"7_paid_meals_social_studies_pass_",
       :"7_freereduced_price_meals_social_studies_pass_",
       :"8_paid_meals_social_studies_pass_",
       :"8_freereduced_price_meals_social_studies_pass_"
     )
  end

  source("in_2015_subgroup_district_english_ethnicity_combined_header.txt",[], col_sep: "\t") do |s|
    s.transform('Set entity_level to district, parse out state results', WithBlock) do |row|
      if row[:corporation_id] =~ /grand total/i
        row[:corporation_id]='state'
        row[:corporation_name]='state'
        row[:entity_level]='state'
      else
        row[:entity_level]='district'
      end
      row
    end
    .transform('',WithBlock) do |row|
      require 'byebug'
      byebug
    end
    .transform('Rename district id and name columns', MultiFieldRenamer,
    {
      corporation_id: :district_id,
      corporation_name: :district_name
    })
    .transform('Transpose value columns', Transposer,
       :grade_breakdown_subject,
       :value_float,
       :"3_american_indian_ela_pass_",
       :"3_black_ela_pass_",
       :"3_hispanic_ela_pass_",
       :"3_white_ela_pass_",
       :"3_multiracial_ela_pass_",
       :"3_native_hawaiian_or_other_pacific_islander_ela_pass_",
       :"3_asian_ela_pass_",
       :"4_unknown_ela_pass_",
       :"4_american_indian_ela_pass_",
       :"4_black_ela_pass_",
       :"4_hispanic_ela_pass_",
       :"4_white_ela_pass_",
       :"4_multiracial_ela_pass_",
       :"4_native_hawaiian_or_other_pacific_islander_ela_pass_",
       :"4_asian_ela_pass_",
       :"5_unknown_ela_pass_",
       :"5_american_indian_ela_pass_",
       :"5_black_ela_pass_",
       :"5_hispanic_ela_pass_",
       :"5_white_ela_pass_",
       :"5_multiracial_ela_pass_",
       :"5_native_hawaiian_or_other_pacific_islander_ela_pass_",
       :"5_asian_ela_pass_",
       :"6_unknown_ela_pass_",
       :"6_american_indian_ela_pass_",
       :"6_black_ela_pass_",
       :"6_hispanic_ela_pass_",
       :"6_white_ela_pass_",
       :"6_multiracial_ela_pass_",
       :"6_native_hawaiian_or_other_pacific_islander_ela_pass_",
       :"6_asian_ela_pass_",
       :"7_american_indian_ela_pass_",
       :"7_black_ela_pass_",
       :"7_hispanic_ela_pass_",
       :"7_white_ela_pass_",
       :"7_multiracial_ela_pass_",
       :"7_native_hawaiian_or_other_pacific_islander_ela_pass_",
       :"7_asian_ela_pass_",
       :"8_unknown_ela_pass_",
       :"8_american_indian_ela_pass_",
       :"8_black_ela_pass_",
       :"8_hispanic_ela_pass_",
       :"8_white_ela_pass_",
       :"8_multiracial_ela_pass_",
       :"8_native_hawaiian_or_other_pacific_islander_ela_pass_",
       :"8_asian_ela_pass_"
     )
  end

  #BAD DATA!!!!
  # source("in_2015_subgroup_district_english_gender_combined_header.txt",[], col_sep: "\t") do |s|
  #   s.transform('Set entity_level to district, parse out state results', WithBlock) do |row|
  #     if row[:corporation_id] =~ /grand total/i
  #       row[:corporation_id]='state'
  #       row[:corporation_name]='state'``
  #       row[:entity_level]='state'
  #     else
  #       row[:entity_level]='district'
  #     end
  #     row
  #   end
  #   .transform('Rename district id and name columns', MultiFieldRenamer,
  #   {
  #     corporation_id: :district_id,
  #     corporation_name: :district_name
  #   })
  #   .transform('',WithBlock) do |row|
  #     require 'byebug'
  #     byebug
  #   end
  #   .transform('Transpose value columns', Transposer,
  #      :grade_breakdown_subject,
  #      :value_float,
  #      :"8_asian_ela_pass_",
  #      :"3_female_ela_pass_",
  #      :"3_male_ela_pass_",
  #      :"4_female_ela_pass_",
  #      :"4_male_ela_pass_",
  #      :"5_female_ela_pass_",
  #      :"5_male_ela_pass_",
  #      :"6_female_ela_pass_",
  #      :"6_male_ela_pass_",
  #      :"7_female_ela_pass_",
  #      :"7_male_ela_pass_",
  #      :"8_female_ela_pass_",
  #      :"8_male_ela_pass_"
  #    )
  # end
  #
  # source("in_2015_subgroup_district_english_ses_combined_header.txt",[], col_sep: "\t") do |s|
  #   s.transform('Set entity_level to district, parse out state results', WithBlock) do |row|
  #     if row[:corporation_id] =~ /grand total/i
  #       row[:corporation_id]='state'
  #       row[:corporation_name]='state'
  #       row[:entity_level]='state'
  #     else
  #       row[:entity_level]='district'
  #     end
  #     row
  #   end
  #   .transform('Rename district id and name columns', MultiFieldRenamer,
  #   {
  #     corporation_id: :district_id,
  #     corporation_name: :district_name
  #   })
  #   .transform('Transpose value columns', Transposer,
  #      :grade_breakdown_subject,
  #      :value_float,
  #      :"3_paid_meals_ela_pass_",
  #      :"3_freereduced_price_meals_ela_pass_",
  #      :"4_paid_meals_ela_pass_",
  #      :"4_freereduced_price_meals_ela_pass_",
  #      :"5_paid_meals_ela_pass_",
  #      :"5_freereduced_price_meals_ela_pass_",
  #      :"6_paid_meals_ela_pass_",
  #      :"6_freereduced_price_meals_ela_pass_",
  #      :"7_paid_meals_ela_pass_",
  #      :"7_freereduced_price_meals_ela_pass_",
  #      :"8_paid_meals_ela_pass_",
  #      :"8_freereduced_price_meals_ela_pass_"
  #    )
  # end

  source("in_2015_subgroup_district_math_ethnicity_combined_header.txt",[], col_sep: "\t") do |s|
    s.transform('Set entity_level to district, parse out state results', WithBlock) do |row|
      if row[:corporation_id] =~ /grand total/i
        row[:corporation_id]='state'
        row[:corporation_name]='state'
        row[:entity_level]='state'
      else
        row[:entity_level]='district'
      end
      row
    end
    .transform('Rename district id and name columns', MultiFieldRenamer,
    {
      corporation_id: :district_id,
      corporation_name: :district_name
    })
    .transform('Transpose value columns', Transposer,
       :grade_breakdown_subject,
       :value_float,
       :"3_american_indian_math_pass_",
       :"3_black_math_pass_",
       :"3_hispanic_math_pass_",
       :"3_white_math_pass_",
       :"3_multiracial_math_pass_",
       :"3_native_hawaiian_or_other_pacific_islander_math_pass_",
       :"3_asian_math_pass_",
       :"4_unknown_math_pass_",
       :"4_american_indian_math_pass_",
       :"4_black_math_pass_",
       :"4_hispanic_math_pass_",
       :"4_white_math_pass_",
       :"4_multiracial_math_pass_",
       :"4_native_hawaiian_or_other_pacific_islander_math_pass_",
       :"4_asian_math_pass_",
       :"5_unknown_math_pass_",
       :"5_american_indian_math_pass_",
       :"5_black_math_pass_",
       :"5_hispanic_math_pass_",
       :"5_white_math_pass_",
       :"5_multiracial_math_pass_",
       :"5_native_hawaiian_or_other_pacific_islander_math_pass_",
       :"5_asian_math_pass_",
       :"6_unknown_math_pass_",
       :"6_american_indian_math_pass_",
       :"6_black_math_pass_",
       :"6_hispanic_math_pass_",
       :"6_white_math_pass_",
       :"6_multiracial_math_pass_",
       :"6_native_hawaiian_or_other_pacific_islander_math_pass_",
       :"6_asian_math_pass_",
       :"7_american_indian_math_pass_",
       :"7_black_math_pass_",
       :"7_hispanic_math_pass_",
       :"7_white_math_pass_",
       :"7_multiracial_math_pass_",
       :"7_native_hawaiian_or_other_pacific_islander_math_pass_",
       :"7_asian_math_pass_",
       :"8_unknown_math_pass_",
       :"8_american_indian_math_pass_",
       :"8_black_math_pass_",
       :"8_hispanic_math_pass_",
       :"8_white_math_pass_",
       :"8_multiracial_math_pass_",
       :"8_native_hawaiian_or_other_pacific_islander_math_pass_",
       :"8_asian_math_pass_"
     )
  end

  source("in_2015_subgroup_district_math_gender_combined_header.txt",[], col_sep: "\t") do |s|
    s.transform('Set entity_level to district, parse out state results', WithBlock) do |row|
      if row[:corporation_id] =~ /grand total/i
        row[:corporation_id]='state'
        row[:corporation_name]='state'
        row[:entity_level]='state'
      else
        row[:entity_level]='district'
      end
      row
    end
    .transform('Rename district id and name columns', MultiFieldRenamer,
    {
      corporation_id: :district_id,
      corporation_name: :district_name
    })
    .transform('Transpose value columns', Transposer,
       :grade_breakdown_subject,
       :value_float,
       :"8_asian_math_pass_",
       :"3_female_math_pass_",
       :"3_male_math_pass_",
       :"4_female_math_pass_",
       :"4_male_math_pass_",
       :"5_female_math_pass_",
       :"5_male_math_pass_",
       :"6_female_math_pass_",
       :"6_male_math_pass_",
       :"7_female_math_pass_",
       :"7_male_math_pass_",
       :"8_female_math_pass_",
       :"8_male_math_pass_"
     )

  end

  source("in_2015_subgroup_district_math_ses_combined_header.txt",[], col_sep: "\t") do |s|
    s.transform('Set entity_level to district, parse out state results', WithBlock) do |row|
      if row[:corporation_id] =~ /grand total/i
        row[:corporation_id]='state'
        row[:corporation_name]='state'
        row[:entity_level]='state'
      else
        row[:entity_level]='district'
      end
      row
    end
    .transform('Rename district id and name columns', MultiFieldRenamer,
    {
      corporation_id: :district_id,
      corporation_name: :district_name
    })
    .transform('Transpose value columns', Transposer,
       :grade_breakdown_subject,
       :value_float,
       :"3_paid_meals_math_pass_",
       :"3_freereduced_price_meals_math_pass_",
       :"4_paid_meals_math_pass_",
       :"4_freereduced_price_meals_math_pass_",
       :"5_paid_meals_math_pass_",
       :"5_freereduced_price_meals_math_pass_",
       :"6_paid_meals_math_pass_",
       :"6_freereduced_price_meals_math_pass_",
       :"7_paid_meals_math_pass_",
       :"7_freereduced_price_meals_math_pass_",
       :"8_paid_meals_math_pass_",
       :"8_freereduced_price_meals_math_pass_"
     )
  end

  source("in_2015_subgroup_district_science_ethnicity_combined_header.txt",[], col_sep: "\t") do |s|
    s.transform('Set entity_level to district, parse out state results', WithBlock) do |row|
      if row[:corporation_id] =~ /grand total/i
        row[:corporation_id]='state'
        row[:corporation_name]='state'
        row[:entity_level]='state'
      else
        row[:entity_level]='district'
      end
      row
    end
    .transform('Rename district id and name columns', MultiFieldRenamer,
    {
      corporation_id: :district_id,
      corporation_name: :district_name
    })
    .transform('Transpose value columns', Transposer,
       :grade_breakdown_subject,
       :value_float,
       :"3_american_indian_science_pass_",
       :"3_black_science_pass_",
       :"3_hispanic_science_pass_",
       :"3_white_science_pass_",
       :"3_multiracial_science_pass_",
       :"3_native_hawaiian_or_other_pacific_islander_science_pass_",
       :"3_asian_science_pass_",
       :"4_unknown_science_pass_",
       :"4_american_indian_science_pass_",
       :"4_black_science_pass_",
       :"4_hispanic_science_pass_",
       :"4_white_science_pass_",
       :"4_multiracial_science_pass_",
       :"4_native_hawaiian_or_other_pacific_islander_science_pass_",
       :"4_asian_science_pass_",
       :"5_unknown_science_pass_",
       :"5_american_indian_science_pass_",
       :"5_black_science_pass_",
       :"5_hispanic_science_pass_",
       :"5_white_science_pass_",
       :"5_multiracial_science_pass_",
       :"5_native_hawaiian_or_other_pacific_islander_science_pass_",
       :"5_asian_science_pass_",
       :"6_unknown_science_pass_",
       :"6_american_indian_science_pass_",
       :"6_black_science_pass_",
       :"6_hispanic_science_pass_",
       :"6_white_science_pass_",
       :"6_multiracial_science_pass_",
       :"6_native_hawaiian_or_other_pacific_islander_science_pass_",
       :"6_asian_science_pass_",
       :"7_american_indian_science_pass_",
       :"7_black_science_pass_",
       :"7_hispanic_science_pass_",
       :"7_white_science_pass_",
       :"7_multiracial_science_pass_",
       :"7_native_hawaiian_or_other_pacific_islander_science_pass_",
       :"7_asian_science_pass_",
       :"8_unknown_science_pass_",
       :"8_american_indian_science_pass_",
       :"8_black_science_pass_",
       :"8_hispanic_science_pass_",
       :"8_white_science_pass_",
       :"8_multiracial_science_pass_",
       :"8_native_hawaiian_or_other_pacific_islander_science_pass_",
       :"8_asian_science_pass_"
     )
  end

  source("in_2015_subgroup_district_science_gender_combined_header.txt",[], col_sep: "\t") do |s|
    s.transform('Set entity_level to district, parse out state results', WithBlock) do |row|
      if row[:corporation_id] =~ /grand total/i
        row[:corporation_id]='state'
        row[:corporation_name]='state'
        row[:entity_level]='state'
      else
        row[:entity_level]='district'
      end
      row
    end
    .transform('Rename district id and name columns', MultiFieldRenamer,
    {
      corporation_id: :district_id,
      corporation_name: :district_name
    })
    .transform('Transpose value columns', Transposer,
       :grade_breakdown_subject,
       :value_float,
       :"8_asian_science_pass_",
       :"3_female_science_pass_",
       :"3_male_science_pass_",
       :"4_female_science_pass_",
       :"4_male_science_pass_",
       :"5_female_science_pass_",
       :"5_male_science_pass_",
       :"6_female_science_pass_",
       :"6_male_science_pass_",
       :"7_female_science_pass_",
       :"7_male_science_pass_",
       :"8_female_science_pass_",
       :"8_male_science_pass_"
     )

  end

  source("in_2015_subgroup_district_science_ses_combined_header.txt",[], col_sep: "\t") do |s|
    s.transform('Set entity_level to district, parse out state results', WithBlock) do |row|
  if row[:corporation_id] =~ /grand total/i
    row[:corporation_id]='state'
    row[:corporation_name]='state'
    row[:entity_level]='state'
  else
    row[:entity_level]='district'
  end
  row
end
    .transform('Rename district id and name columns', MultiFieldRenamer,
    {
      corporation_id: :district_id,
      corporation_name: :district_name
    })
    .transform('Transpose value columns', Transposer,
       :grade_breakdown_subject,
       :value_float,
       :"3_paid_meals_science_pass_",
       :"3_freereduced_price_meals_science_pass_",
       :"4_paid_meals_science_pass_",
       :"4_freereduced_price_meals_science_pass_",
       :"5_paid_meals_science_pass_",
       :"5_freereduced_price_meals_science_pass_",
       :"6_paid_meals_science_pass_",
       :"6_freereduced_price_meals_science_pass_",
       :"7_paid_meals_science_pass_",
       :"7_freereduced_price_meals_science_pass_",
       :"8_paid_meals_science_pass_",
       :"8_freereduced_price_meals_science_pass_"
     )
  end

  source("in_2015_subgroup_district_social_studies_ethnicity_combined_header.txt",[], col_sep: "\t") do |s|
    s.transform('Set entity_level to district, parse out state results', WithBlock) do |row|
      if row[:corporation_id] =~ /grand total/i
        row[:corporation_id]='state'
        row[:corporation_name]='state'
        row[:entity_level]='state'
      else
        row[:entity_level]='district'
      end
      row
    end
    .transform('Rename district id and name columns', MultiFieldRenamer,
    {
      corporation_id: :district_id,
      corporation_name: :district_name
    })
    .transform('Transpose value columns', Transposer,
       :grade_breakdown_subject,
       :value_float,
       :"3_american_indian_social_studies_pass_",
       :"3_black_social_studies_pass_",
       :"3_hispanic_social_studies_pass_",
       :"3_white_social_studies_pass_",
       :"3_multiracial_social_studies_pass_",
       :"3_native_hawaiian_or_other_pacific_islander_social_studies_pass_",
       :"3_asian_social_studies_pass_",
       :"4_unknown_social_studies_pass_",
       :"4_american_indian_social_studies_pass_",
       :"4_black_social_studies_pass_",
       :"4_hispanic_social_studies_pass_",
       :"4_white_social_studies_pass_",
       :"4_multiracial_social_studies_pass_",
       :"4_native_hawaiian_or_other_pacific_islander_social_studies_pass_",
       :"4_asian_social_studies_pass_",
       :"5_unknown_social_studies_pass_",
       :"5_american_indian_social_studies_pass_",
       :"5_black_social_studies_pass_",
       :"5_hispanic_social_studies_pass_",
       :"5_white_social_studies_pass_",
       :"5_multiracial_social_studies_pass_",
       :"5_native_hawaiian_or_other_pacific_islander_social_studies_pass_",
       :"5_asian_social_studies_pass_",
       :"6_unknown_social_studies_pass_",
       :"6_american_indian_social_studies_pass_",
       :"6_black_social_studies_pass_",
       :"6_hispanic_social_studies_pass_",
       :"6_white_social_studies_pass_",
       :"6_multiracial_social_studies_pass_",
       :"6_native_hawaiian_or_other_pacific_islander_social_studies_pass_",
       :"6_asian_social_studies_pass_",
       :"7_american_indian_social_studies_pass_",
       :"7_black_social_studies_pass_",
       :"7_hispanic_social_studies_pass_",
       :"7_white_social_studies_pass_",
       :"7_multiracial_social_studies_pass_",
       :"7_native_hawaiian_or_other_pacific_islander_social_studies_pass_",
       :"7_asian_social_studies_pass_",
       :"8_unknown_social_studies_pass_",
       :"8_american_indian_social_studies_pass_",
       :"8_black_social_studies_pass_",
       :"8_hispanic_social_studies_pass_",
       :"8_white_social_studies_pass_",
       :"8_multiracial_social_studies_pass_",
       :"8_native_hawaiian_or_other_pacific_islander_social_studies_pass_",
       :"8_asian_social_studies_pass_"
     )
  end

  source("in_2015_subgroup_district_social_studies_gender_combined_header.txt",[], col_sep: "\t") do |s|
    s.transform('Set entity_level to district, parse out state results', WithBlock) do |row|
  if row[:corporation_id] =~ /grand total/i
    row[:corporation_id]='state'
    row[:corporation_name]='state'
    row[:entity_level]='state'
  else
    row[:entity_level]='district'
  end
  row
end
    .transform('Rename district id and name columns', MultiFieldRenamer,
    {
      corporation_id: :district_id,
      corporation_name: :district_name
    })
    .transform('Transpose value columns', Transposer,
       :grade_breakdown_subject,
       :value_float,
       :"8_asian_social_studies_pass_",
       :"3_female_social_studies_pass_",
       :"3_male_social_studies_pass_",
       :"4_female_social_studies_pass_",
       :"4_male_social_studies_pass_",
       :"5_female_social_studies_pass_",
       :"5_male_social_studies_pass_",
       :"6_female_social_studies_pass_",
       :"6_male_social_studies_pass_",
       :"7_female_social_studies_pass_",
       :"7_male_social_studies_pass_",
       :"8_female_social_studies_pass_",
       :"8_male_social_studies_pass_"
     )

  end

  source("in_2015_subgroup_district_social_studies_ses_combined_header.txt",[], col_sep: "\t") do |s|
    s.transform('Set entity_level to district, parse out state results', WithBlock) do |row|
      if row[:corporation_id] =~ /grand total/i
        row[:corporation_id]='state'
        row[:corporation_name]='state'
        row[:entity_level]='state'
      else
        row[:entity_level]='district'
      end
      row
    end
    .transform('Rename district id and name columns', MultiFieldRenamer,
    {
      corporation_id: :district_id,
      corporation_name: :district_name
    })
    .transform('Transpose value columns', Transposer,
       :grade_breakdown_subject,
       :value_float,
       :"3_paid_meals_social_studies_pass_",
       :"3_freereduced_price_meals_social_studies_pass_",
       :"4_paid_meals_social_studies_pass_",
       :"4_freereduced_price_meals_social_studies_pass_",
       :"5_paid_meals_social_studies_pass_",
       :"5_freereduced_price_meals_social_studies_pass_",
       :"6_paid_meals_social_studies_pass_",
       :"6_freereduced_price_meals_social_studies_pass_",
       :"7_paid_meals_social_studies_pass_",
       :"7_freereduced_price_meals_social_studies_pass_",
       :"8_paid_meals_social_studies_pass_",
       :"8_freereduced_price_meals_social_studies_pass_"
     )
  end

  breakdown_id_map={
    'american_indian' => 4,
    'black' => 3,
    'hispanic' => 6,
    'white' => 8,
    'multiracial' => 21,
    'native_hawaiian_or_other_pacific_islander' => 112,
    'asian' => 2,
    'female' => 11,
    'male' => 12,
    'paid_meals' => 10,
    'freereduced_price_meals' => 9
  }

  subject_id_map={
    'ela' => 4,
    'math' => 5,
    'science' => 25,
    'social_studies' => 24
  }

  shared do |s|
    s.transform('Remove combined header columns', ColumnSelector,
         :entity_level,
         :district_id,
         :district_name,
         :school_id,
         :school_name,
         :grade_breakdown_subject,
         :value_float,
         :grade,
         :breakdown,
         :subject)
    .transform('Create state_id column', WithBlock) do |row|
      row[:entity_level]=='school' ? row[:state_id]=row[:school_id] : row[:state_id]=row[:district_id]
      row
    end
    .transform('Remove % from value_float', WithBlock) do |row|
      row[:value_float].gsub!('%','') if row[:value_float]
      row
    end
    .transform('Split grade_breakdown_subject', WithBlock) do |row|
     grade_breakdown_subject=row[:grade_breakdown_subject].to_s.split('_')

     grade_breakdown_subject.delete_at(-1)
     row[:grade]=grade_breakdown_subject[0]
     grade_breakdown_subject.delete_at(0)
     row[:subject]=grade_breakdown_subject[-1]
     grade_breakdown_subject.delete_at(-1)

     if row[:subject]=='studies'
       row[:subject]='social_studies'
       grade_breakdown_subject.delete_at(-1)
     end

     row[:breakdown]=grade_breakdown_subject.join('_')
     row
   end
   .transform('Fill default columns', Fill, {
      year: 2015,
      entity_type: 'public_charter',
      proficiency_band: 'null',
      proficiency_band_id: 'null',
      number_tested: nil,
      level_code: 'e,m,h',
      test_data_type: 'istep',
      test_data_type_id: 49,
      })
    .transform('Remove Unknown breakdown', DeleteRows, :breakdown, /unknown/i)
    .transform('Look up breakdown ids', HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id)
    .transform('Look up subject ids', HashLookup, :subject, subject_id_map, to: :subject_id)
    .transform('Remove rows with nil value_float', DeleteRows, :value_float, nil)
  end

  def config_hash
    {
      source_id: 29,
      state: 'in',
      notes: 'DXT-1567: IN ISTEP 2015 Subgroups test load.',
      url: 'http://www.doe.in.gov/accountability/find-school-and-corporation-data-reports',
      file: 'ok/2015/output/in.2015.2.public.charter.[level].txt',
      level: nil,
      school_type: 'public,charter'
    }
  end
end

INTestProcessor2015ISTEPSubgroups.new(ARGV[0], max: nil, offset: nil).run
