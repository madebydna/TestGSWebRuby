require 'active_support/concern'

module ReadOnlyRecord
  extend ActiveSupport::Concern

  included do
    before_destroy :before_destroy_read_only
  end

  def create_or_update
    raise ActiveRecord::ReadOnlyRecord, "Not allowed to modify #{self.class} with id #{id}" if readonly?
    result = new_record? ? create : update
    result != false
  end

  def readonly?
    new_record? ? false : true
  end

  def before_destroy_read_only
    raise ActiveRecord::ReadOnlyRecord, "Not allowed to destroy #{self.class} with id #{id}"
  end

end