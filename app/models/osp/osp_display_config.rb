class OspDisplayConfig < ActiveRecord::Base

  include JsonifiedAttributeConcerns

  db_magic :connection => :gs_schooldb
  self.table_name = 'osp_display_configs'

  attr_accessible :location_group_id, :osp_question_id, :osp_question_group_id, :order_in_group, :order_on_page, :page_name, :config ,:active,  :updated

  scope :active, -> { where(active: true) }


  belongs_to :osp_question, :class_name => 'OspQuestion', foreign_key: 'osp_question_id'
  belongs_to :osp_question_group, :class_name => 'OspQuestionGroup',foreign_key: 'osp_question_group_id'

  jsonified_attribute :answers, :label, :validations, :options, :question_ids, :year_display, json_attribute: :config, type: :string

  def self.find_by_page(page)
    self.active.where(page_name: page).order(:order_on_page,:order_in_group)
  end

  def self.find_by_page_and_group(page, group)
    self.active.where(page_name: page, osp_question_group_id: group).order(:order_on_page,:order_in_group)
  end


  def self.find_by_page_and_school(page,school)
    self.find_by_page(page).select do |osp_display_config|
      osp_display_config.osp_question.school_type.include?(school.type) &&
      school.includes_level_code?(osp_display_config.osp_question.level_code) && osp_display_config.osp_question.active
    end
  end

  def children
    @children = [*OspQuestion.find([*question_ids])]
  end

  def question_type
    osp_question.question_type
  end

  def displayed_label
    if self.label.present?
       self.label
    else
      osp_question.question_label
    end
  end

  def question_response_key
    osp_question.esp_response_key
  end

  def displayed_answers
    if self.answers.present?
      self.answers
    else
      osp_question.answers
    end
  end

  def display_options
    options || osp_question.options || {}
  end

  def group_heading
    osp_question_group.heading
  end

  def display_validations
    if self.validations.present?
      self.validations
    else
      osp_question.validations
    end
  end

  def years_display
    if self.year_display.present?
      self.year_display
    else
      osp_question.year_display
    end
  end


end
