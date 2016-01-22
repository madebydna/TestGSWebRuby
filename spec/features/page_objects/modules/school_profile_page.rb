require 'features/page_objects/modules/school_profile_header'

module SchoolProfilePage
  def self.included(page_class)
    page_class.class_eval do
      include SchoolProfileHeader
    end
  end
end