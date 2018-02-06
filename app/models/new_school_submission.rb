# frozen_string_literal: true

class NewSchoolSubmission < ActiveRecord::Base
  self.table_name = 'new_school_submissions'
  db_magic :connection => :gs_schooldb
  validates :district_name, :county, presence: true
  validates :school_name, presence: true, length: {maximum: 100 }
  validates :zip_code, length: {is: 5}, numericality: { only_integer: true }
  validates :state_school_id, presence: true, allow_blank: true
  validate :valid_grades?, :valid_nces_code?, :valid_school_type?, :valid_state?

  before_save :add_level_code

  SCHOOL_TYPE_TO_NCES_CODE = {
    'private' => 8,
    'public' => 12,
    'charter' => 12
  }

  #--------- Custom validations ----------#
  def valid_grades?
    unless grades && grades.split(',').all? {|grade| LevelCode::GRADES_WHITELIST.include?(grade.downcase)}
      errors.add(:grades, 'must be pk, kg, or grades 1-12.')
    end
  end

  def valid_nces_code?
    unless nces_code.blank? || nces_code.length == SCHOOL_TYPE_TO_NCES_CODE[school_type]
      errors.add(:nces_code, 'must be 8 characters for private schools and 12 characters for public/charter schools')
    end
  end

  def valid_school_type?
    unless school_type && SCHOOL_TYPE_TO_NCES_CODE.keys.include?(school_type.downcase)
      errors.add(:school_type, 'must be either public, private, or charter.')
    end
  end

  def valid_state?
    unless state && States.abbreviations.include?(state)
      errors.add(:state, 'must be valid two-letter abbreviation for one of the fifty U.S. states.')
    end
  end
  #---------end custom validations-----------#

  def add_level_code
    self.level = LevelCode.from_all_grades(self.grades) unless grades.nil?
  end

end