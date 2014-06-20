class EspEnrollmentDecorator
  attr_accessor :esp_hash

  def initialize(esp_hash)
    @esp_hash = Hashie::Mash.new esp_hash
  end

  def application_deadline
    deadline = esp_hash.application_deadline
    if deadline == 'date'
      esp_hash.application_deadline_date
    elsif deadline == 'yearround'
      'Rolling deadline'
    elsif deadline == 'parents_contact'
      'Contact school'
    end
  end

end