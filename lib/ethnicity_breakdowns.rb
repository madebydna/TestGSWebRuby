module EthnicityBreakdowns
  ETHNICITY_BREAKDOWNS = ["All students",
                          "White",
                          "Hispanic",
                          "Black",
                          "Two or more races",
                          "Asian or Asian/Pacific Islander",
                          "American Indian/Alaska Native",
                          "Asian",
                          "Native American or Native Alaskan",
                          "Multiracial",
                          "African American",
                          "Native Hawaiian or Other Pacific Islander",
                          "Hawaiian Native/Pacific Islander",
                          "Pacific Islander",
                          "Asian or Pacific Islander",
                          "Filipino",
                          "Native American",
                          "Hawaiian",
                          "Asian/Pacific Islander",
                          "Black, not Hispanic",
                          "White, not Hispanic",
                          "American Indian/Alaskan Native",
                          "Native Hawaiian or Pacific Islander",
                          "Unspecified",
                          "African-American",
                          "Native Hawaiian",
                          "American Indian"
                        ]

  ETHNICITY_HASH = ETHNICITY_BREAKDOWNS.each_with_object({}) {|v,h| h[v] = true}


  def self.ethnicity_breakdown?(bd)
    ETHNICITY_HASH[bd]
  end

end