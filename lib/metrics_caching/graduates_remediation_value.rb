module MetricsCaching
  module GraduatesRemediationValue
    def data_type
      if !all_subjects?
        @data_type.gsub(/^Percent [Nn]eeding (.+)$/, "Graduates needing #{subject.capitalize} \\1")
      elsif subject == 'Any Subject'
        @data_type.gsub(/^(Percent [Nn]eeding) (.+)$/, "\\1 any \\2")
      else
        @data_type
      end
    end
  end
end