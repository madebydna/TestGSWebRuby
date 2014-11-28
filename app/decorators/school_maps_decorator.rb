class SchoolMapsDecorator < Draper::Decorator
  decorates :school
  delegate_all

  include GradeLevelConcerns

  def grade_range
    process_level
  end

  def school_type
    if type == 'Charter'
      'Public charter'
    elsif type == 'Public'
      'Public district'
    else
      'Private'
    end
  end

end