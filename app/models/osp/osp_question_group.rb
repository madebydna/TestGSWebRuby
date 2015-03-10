class Osp::OspQuestionGroup < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'osp_question_groups'

  attr_accessible :image, :heading, :subtext, :default_config ,:active,  :updated
  has_many :osp_display_configs, :class_name => 'Osp::OspDisplayConfig'

  scope :active, -> { where(active: true) }


end
