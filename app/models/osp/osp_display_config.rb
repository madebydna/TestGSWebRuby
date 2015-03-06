class Osp::OspDisplayConfig < ActiveRecord::Base

  include JsonifiedAttributeConcerns

  db_magic :connection => :gs_schooldb
  self.table_name = 'osp_display_configs'

  attr_accessible :location_group_id, :osp_question_id, :osp_question_group_id, :order_in_group, :order_on_page, :page_name, :config ,:active,  :updated

  scope :active, -> { where(active: true) }

  scope :for_question, ->(question) { where(school_id: school.id, state: school.state) }

  belongs_to :osp_question, :class_name => 'Osp::OspQuestion', foreign_key: 'osp_question_id'
  belongs_to :osp_question_group, :class_name => 'Osp::OspQuestionGroup',foreign_key: 'osp_question_group_id'

  jsonified_attribute :answers, :label, json_attribute: :config, type: :string

  def self.find_by_page(page)
    self.active.where(page_name: page).order(:order_on_page)
  end


  def self.find_by_page_and_school(page,school)
    self.find_by_page(page).select do |osp_display_config|
      osp_display_config.osp_question.school_type.include?(school.type) &&
      school.includes_level_code?(osp_display_config.osp_question.level_code) && osp_display_config.osp_question.active
    end
  end

  def displayed_label
    if self.label.present?
       self.label
    else
      osp_question.question_label
    end
  end

  def displayed_answers
    if self.answers.present?
      self.answers
    else
      osp_question.answers
    end
  end


end
