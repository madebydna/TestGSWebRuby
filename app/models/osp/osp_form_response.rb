class Osp::OspFormResponse < ActiveRecord::Base

  include JsonifiedAttributeConcerns

  db_magic :connection => :gs_schooldb
  self.table_name = 'osp_form_responses'

  attr_accessible :esp_membership_id, :osp_question_id,:responses, :updated

  belongs_to :esp_membership, foreign_key: 'esp_membership_id'

  belongs_to :osp_question, :class_name => 'Osp::OspQuestion', foreign_key: 'osp_question_id'

  jsonified_attribute :responses, json_attribute: :responses, type: :string

end
