class WidgetLog < ActiveRecord::Base
  db_magic :connection => :gs_schooldb

  validates_presence_of :email
  validates_format_of :email, :with => /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/, message: 'Please enter a valid email address.'

end
