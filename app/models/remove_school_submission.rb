# frozen_string_literal: true

class RemoveSchoolSubmission < ActiveRecord::Base
  self.table_name = 'remove_school_submissions'
  db_magic :connection => :gs_schooldb

  validates :submitter_email, length: {maximum: 100 }, presence: true
  validates :submitter_role, presence: true
  validates :evidence_url, length: {maximum: 100}, allow_blank: true
  validate :well_formed_gs_url?

  def well_formed_gs_url?
    unless gs_url.include?('www.greatschools.org/') && gs_url.length <= 100
      errors.add(:greatschools, 'web link is not valid.')
    end
  end
end