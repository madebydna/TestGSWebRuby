require "spec_helper"

describe SchoolProfiles::NarrativeLowIncomeTestScores do

  describe "#new" do
    it "should change test score hash correctly" do
      school_cache_data_reader = mock_school_cache_data_reader

      narrativeLowIncomeTestScores = SchoolProfiles::NarrativeLowIncomeTestScores.new(school_cache_data_reader: school_cache_data_reader)
      allow(narrativeLowIncomeTestScores).to receive(:key_for_yml).and_return '4'
      narrativeLowIncomeTestScores.auto_narrative_calculate_and_add

      expect(school_cache_data_reader.test_scores).to eq(result_hash)
    end

    it 'should change a test score hash with alternate level code and subject names correctly' do
      school_cache_data_reader = double(test_scores: test_scores_hash_2)

      narrativeLowIncomeTestScores = SchoolProfiles::NarrativeLowIncomeTestScores.new(school_cache_data_reader: school_cache_data_reader)
      allow(narrativeLowIncomeTestScores).to receive(:key_for_yml).and_return '4'
      narrativeLowIncomeTestScores.auto_narrative_calculate_and_add

      expect(school_cache_data_reader.test_scores).to eq(result_hash_2)
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
                     "narrative" => t('4', 'English')

                   }
                 },
                 "Math"=>
                 {
                   "2015"=>
                   {
                     "number_students_tested"=>98,
                     "score"=>47.0,
                     "state_average"=>21.0,
                     "narrative" => t('4', 'math') 
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

  def result_hash_2
    {"15" =>
     {
       "All"=>
       {
         "grades"=>
         {
           "All"=>
           {
             "level_code"=>
             {
               "m,h"=>
               {
                 "Some subject"=>
                 {
                   "2015"=>
                   {
                     "number_students_tested"=>344,
                     "score"=>72.0,
                     "state_average"=>44.0
                   }
                 },
                 "Some other subject"=>
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
         }
       },
       "Not economically disadvantaged"=>
       {
         "grades"=>
         {"All"=>
          {
            "level_code"=>
            {"m,h"=>
             {"Some subject"=>
              {"2015"=>
               {"number_students_tested"=>245,
                "score"=>78.0,
                "state_average"=>64.0
               }
              },
              "Some other subject"=>
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
         }
       },
       "Economically disadvantaged"=>
       {
         "grades"=>
         {
           "All"=>
           {
             "level_code"=>
             {
               "m,h"=>
               {
                 "Some subject"=>
                 {
                   "2015"=>
                   {
                     "number_students_tested"=>99,
                     "score"=>56.0,
                     "state_average"=>30.0,
                     "narrative" => t('4', 'Some subject')

                   }
                 },
                 "Some other subject"=>
                 {
                   "2015"=>
                   {
                     "number_students_tested"=>98,
                     "score"=>47.0,
                     "state_average"=>21.0,
                     "narrative" => t('4', 'Some other subject')
                   }
                 }
               }
             }
           }
         }
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

  def test_scores_hash_2
    {"15" =>
     {
       "All"=>
      {
        "grades"=>
          {
            "All"=>
              {
                "level_code"=>
                  {
                    "m,h"=>
                      {
                        "Some subject"=>
                          {
                            "2015"=>
                              {
                                "number_students_tested"=>344,
                                "score"=>72.0,
                                "state_average"=>44.0
                              }
                          },
                        "Some other subject"=>
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
          }
     },
  "Not economically disadvantaged"=>
     {
       "grades"=>
       {"All"=>
         {
          "level_code"=>
            {"m,h"=>
              {"Some subject"=>
                {"2015"=>
                  {"number_students_tested"=>245,
                    "score"=>78.0,
                    "state_average"=>64.0
                  }
                },
              "Some other subject"=>
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
       }
      },
    "Economically disadvantaged"=>
       {
         "grades"=>
         {
          "All"=>
          {
            "level_code"=>
              {
                "m,h"=>
                  {
                    "Some subject"=>
                      {
                        "2015"=>
                        {
                          "number_students_tested"=>99,
                          "score"=>56.0,
                          "state_average"=>30.0}
                        },
                      "Some other subject"=>
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
        }
       }
     }
    }
  end

  def t(yml_key, subject)
    I18n.t(yml_key + '_html', scope: 'lib.test_scores.narrative.low_income', subject: I18n.t(subject, scope: 'lib.equity_gsdata', default: subject))
  end
end
