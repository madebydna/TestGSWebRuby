module BehaviorForModelsWithActiveField
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where(active: 1) }
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

end