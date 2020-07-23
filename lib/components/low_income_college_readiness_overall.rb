# frozen_string_literal: trues

module Components
  class LowIncomeCollegeReadinessOverall < CollegeReadinessOverall
    def breakdown_percentage(value)
      value_to_s(low_income_to_percentages[value.breakdown])
    end
  end
end
