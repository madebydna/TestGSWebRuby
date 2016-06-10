require 'active_support/concern'

module ReadOnlyRecord
  extend ActiveSupport::Concern

  included do
    before_destroy :before_destroy_read_only unless Rails.env.test?
  end

  def readonly?
    new_record? ? false : true
  end

  def before_destroy_read_only
    raise ActiveRecord::ReadOnlyRecord, "Not allowed to destroy #{self.class} with id #{id}"
  end

end