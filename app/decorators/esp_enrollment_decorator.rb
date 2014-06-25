class EspEnrollmentDecorator
  attr_accessor :esp_hash

  def initialize(esp_hash)
    @esp_hash = Hashie::Mash.new esp_hash
  end

  def application_deadline
    deadline = esp_hash.application_deadline
    if deadline == 'date'
      begin
        date = Date.strptime(esp_hash.application_deadline_date, "%m/%d/%Y")
        date.strftime("%B %d, %Y")
      rescue => error
        esp_hash.application_deadline_date
      end
    elsif deadline == 'yearround'
      'Rolling deadline'
    elsif deadline == 'parents_contact'
      'Contact school'
    end
  end
  # Calculated for schools that have the same year for students_accepted_year and applications_received_year (from OSP)
  # Calculation is a rounded number out of 10. Formula is ROUND(students_accepted / applications_received * 10)
  # Schools without data get "no info"
  def enrollment_chances
    return_value = {}
    if esp_hash.students_accepted_year == esp_hash.applications_received_year
      if esp_hash.applications_received.to_i > 0
        return_value =  { 'chance' => ((esp_hash.students_accepted.to_f / esp_hash.applications_received.to_f) * 10).round.to_s, 'year' => esp_hash.applications_received_year }
      end
    end
    return_value
  end

end