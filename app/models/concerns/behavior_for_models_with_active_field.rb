module BehaviorForModelsWithActiveField
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where(active: true) }
    scope :inactive, -> { where(active: false) }
  end

  def active_field_type
    @active_field_type ||= column_for_attribute('active').type
  end

  # When active column is defined in mysql as a bit, then "\x01" indicates true
  # When active column is defined in mysql as an integer, then 1 indicates true
  def active
    read_attribute(:active) == true || read_attribute(:active) == 1 || read_attribute(:active) == "\x01" ? true : false
  end

  def active?
    active == true
  end

  def inactive?
    ! active?
  end

  def activate
    self.active = true
  end

  def deactivate
    self.active = false
  end

  def active=(value)
    if active_field_type == :binary
      truthy_value = "\x01"
      falsey_value = "\x00"
    else
      truthy_value = 1
      falsey_value = 0
    end

    if value == true || value == 1
      write_attribute(:active, truthy_value)
    else
      write_attribute(:active, falsey_value)
    end
  end

end