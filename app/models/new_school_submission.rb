# frozen_string_literal: true

class NewSchoolSubmission < ActiveRecord::Base
  self.table_name = 'new_school_submissions'
  db_magic :connection => :gs_schooldb
  validates :county, :physical_address, :physical_city, :mailing_address,
            :mailing_city, presence: true
  validates :school_name, presence: true, length: {maximum: 100 }
  validates :physical_zip_code, :mailing_zip_code, length: {is: 5}, numericality: { only_integer: true }
  validate :valid_grades, :valid_nces_code, :valid_school_type, :valid_state, :valid_state_school_id,
           :district_required_if_not_private

  SCHOOL_TYPE_TO_NCES_CODE = {
    'private' => 8,
    'public' => 12,
    'charter' => 12
  }

  #--------- Custom validations ----------#
  def valid_grades
    unless grades.present? && grades.split(',').all? {|grade| LevelCode::GRADES_WHITELIST.include?(grade.strip.downcase)}
      errors.add(:grades, 'must be pk, kg, or grades 1-12.')
    end
  end

  def valid_nces_code
    unless pk_only? || well_formed_nces_code?
      errors.add(:nces_code, 'must be 8 characters for private schools and 12 characters for public/charter schools.')
    end
  end

  def valid_state_school_id
    unless pk_only? || state_school_id
      errors.add(:state_school_id, 'is required.')
    end
  end

  def valid_school_type
    unless school_type && SCHOOL_TYPE_TO_NCES_CODE.keys.include?(school_type.downcase)
      errors.add(:school_type, 'must be either public, private, or charter.')
    end
  end

  def valid_state
    unless state && States.abbreviations.include?(state)
      errors.add(:state, 'must be selected from the dropdown menu provided.')
    end
  end

  def district_required_if_not_private
    if school_types_without_private.include?(school_type) && district_name.empty?
      errors.add(:district_name, 'must be present for public/charter schools.')
    end
  end
  #---------end custom validations-----------#

  def add_level_code
    self.level = LevelCode.from_all_grades(self.grades) unless grades.nil?
  end

  def grades=(grades)
    write_attribute(:grades, grades)
    add_level_code
  end

  def pk_only?
    return false if grades.nil?
    grades.strip.downcase == 'pk'
  end

  def well_formed_nces_code?
    nces_code && nces_code.length == SCHOOL_TYPE_TO_NCES_CODE[school_type]
  end

  def school_types_without_private
    SCHOOL_TYPE_TO_NCES_CODE.dup.tap {|hash| hash.delete('private')}
  end

end