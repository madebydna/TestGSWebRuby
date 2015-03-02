class Osp::OspQuestion < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'osp_question'

  attr_accessible :esp_response_key, :question_label, :question_type, :default_config, :school_type, :level_code, :active,  :updated
  belongs_to :osp_display_config, :class_name => 'Osp::OspDisplayConfig'
  scope :active, -> { where(active: true) }



end
