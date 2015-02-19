class Osp::OspQuestionGroup < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'osp_question_group'

  attr_accessible :image, :heading, :subtext, :default_config ,:active,  :updated
  belongs_to :osp_display_config, :class_name => 'Osp::OspDisplayConfig'
  scope :active, -> { where(active: true) }


end
