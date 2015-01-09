module CensusLoading::Subjects

  def convert_subject_to_id(subject)
    if subject
      subject = "All" if subject.downcase == "all subjects"
      sub = CensusLoading::Base.census_data_subjects[subject]
      if sub
        sub.id
      else
        raise "Unknown subject: #{subject}"
      end
    end
  end

end
