# frozen_string_literal: true

class RemoveSchoolSubmission < ActiveRecord::Base
  self.table_name = 'remove_school_submissions'
  db_magic :connection => :gs_schooldb

  validates :submitter_email, :submitter_role, presence: true
  validate :well_formed_gs_url?

  def well_formed_gs_url?
    unless /www.greatschools.org/.match?(gs_url)
      errors.add(:greatschools, 'web link is not valid.')
    end
  end
end