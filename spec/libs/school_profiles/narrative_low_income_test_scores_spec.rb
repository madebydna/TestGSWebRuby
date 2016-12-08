require "spec_helper"

describe SchoolProfiles::NarrativeLowIncomeTestScores do

  describe "#new" do
    it "should change test score hash correctly" do
      school_cache_data_reader = mock_school_cache_data_reader

      narrativeLowIncomeTestScores = SchoolProfiles::NarrativeLowIncomeTestScores.new(school_cache_data_reader: school_cache_data_reader)
      narrativeLowIncomeTestScores.auto_narrative_calculate_and_add

      expect(school_cache_data_reader.test_scores).to eq(result_hash)
    end
  end

  def mock_school_cache_data_reader
   double(test_scores: test_scores_hash)
  end

  def result_hash
    {"236" =>
     {
       "All"=>
       {
         "grades"=>
         {
           "All"=>
           {
             "label"=>"School-wide",
             "level_code"=>
             {
               "e,m,h"=>
               {
                 "English Language Arts"=>
                 {
                   "2015"=>
                   {
                     "number_students_tested"=>344,
                     "score"=>72.0,
                     "state_average"=>44.0
                   }
                 },
                 "Math"=>
                 {
                   "2015"=>
                   {
                     "number_students_tested"=>343,
                     "score"=>55.0,
                     "state_average"=>33.0
                   }
                 }
               }
             }
           }
         },
         "lowest_grade"=>0
       },
       "Not economically disadvantaged"=>
       {
         "grades"=>
         {"All"=>
          {
            "label"=>"School-wide",
            "level_code"=>
            {"e,m,h"=>
             {"English Language Arts"=>
              {"2015"=>
               {"number_students_tested"=>245,
                "score"=>78.0,
                "state_average"=>64.0
               }
              },
              "Math"=>
              {"2015"=>
               {
                 "number_students_tested"=>245,
                 "score"=>58.0,
                 "state_average"=>52.0
               }
              }
             }
            }
          }
         },
         "lowest_grade"=>0
       },
       "Economically disadvantaged"=>
       {
         "grades"=>
         {
           "All"=>
           {
             "label"=>"School-wide",
             "level_code"=>
             {
               "e,m,h"=>
               {
                 "English Language Arts"=>
                 {
                   "2015"=>
                   {
                     "number_students_tested"=>99,
                     "score"=>56.0,
                     "state_average"=>30.0,
                     "narrative" => string_key_for_key_4_3_and_subject_english

                   }
                 },
                 "Math"=>
                 {
                   "2015"=>
                   {
                     "number_students_tested"=>98,
                     "score"=>47.0,
                     "state_average"=>21.0,
                     "narrative" => string_key_for_key_4_3_and_subject_math
                   }
                 }
               }
             }
           }
         },
         "lowest_grade"=>0
       }
     }
    }
  end

  def test_scores_hash
    {"236" =>
     {
       "All"=>
      {
        "grades"=>
          {
            "All"=>
              {
                "label"=>"School-wide",
                "level_code"=>
                  {
                    "e,m,h"=>
                      {
                        "English Language Arts"=>
                          {
                            "2015"=>
                              {
                                "number_students_tested"=>344,
                                "score"=>72.0,
                                "state_average"=>44.0
                              }
                          },
                        "Math"=>
                              {
                                "2015"=>
                                  {
                                    "number_students_tested"=>343,
                                    "score"=>55.0,
                                    "state_average"=>33.0
                                  }
                              }
                      }
                  }
              }
          },
        "lowest_grade"=>0
     },
  "Not economically disadvantaged"=>
     {
       "grades"=>
       {"All"=>
         {
          "label"=>"School-wide",
          "level_code"=>
            {"e,m,h"=>
              {"English Language Arts"=>
                {"2015"=>
                  {"number_students_tested"=>245,
                    "score"=>78.0,
                    "state_average"=>64.0
                  }
                },
              "Math"=>
                {"2015"=>
                  {
                    "number_students_tested"=>245,
                    "score"=>58.0,
                    "state_average"=>52.0
                  }
                }
              }
            }
          }
       },
      "lowest_grade"=>0
      },
    "Economically disadvantaged"=>
       {
         "grades"=>
         {
          "All"=>
          {
            "label"=>"School-wide",
            "level_code"=>
              {
                "e,m,h"=>
                  {
                    "English Language Arts"=>
                      {
                        "2015"=>
                        {
                          "number_students_tested"=>99,
                          "score"=>56.0,
                          "state_average"=>30.0}
                        },
                      "Math"=>
                        {
                          "2015"=>
                            {
                              "number_students_tested"=>98,
                              "score"=>47.0,
                              "state_average"=>21.0}
                        }
                  }
              }
          }
        },
      "lowest_grade"=>0
       }
     }
    }
  end

  def string_key_for_key_4_3_and_subject_english
    "<p class=\"narrative-content\"><span class=\"positive\">A positive sign!</span> The English scores of low-income students at this school are above the state average for all kids. Still, there's a <span class=\"negative\">large gap between how low-income kids</span> are doing compared to their classmates with more financial resources.</p> <p class=\"footnote\"><span class=\"emphasis\">Parents should ask</span> the school what it’s doing to help all students succeed.</p>\n"
    end


  def string_key_for_key_4_3_and_subject_math
    "<p class=\"narrative-content\"><span class=\"positive\">A positive sign!</span> The math scores of low-income students at this school are above the state average for all kids. Still, there's a <span class=\"negative\">large gap between how low-income kids</span> are doing compared to their classmates with more financial resources.</p> <p class=\"footnote\"><span class=\"emphasis\">Parents should ask</span> the school what it’s doing to help all students succeed.</p>\n"
  end
end
