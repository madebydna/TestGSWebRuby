class Osp::OspDisplayConfig < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'osp_display_config'

  attr_accessible :location_group_id, :ques_id, :ques_group_id, :order_in_group, :order_on_page, :page_name, :config ,:active,  :updated

  scope :active, -> { where(active: true) }
  has_many :osp_questions, :class_name => 'Osp::OspQuestion', foreign_key: 'id'
  has_many :osp_question_groups, :class_name => 'Osp::OspQuestionGroup',foreign_key: 'id'



end
