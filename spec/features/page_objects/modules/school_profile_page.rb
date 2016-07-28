require 'features/page_objects/modules/school_profile_header'
require 'features/page_objects/modules/footer'

module SchoolProfilePage
  def self.included(page_class)
    page_class.class_eval do
      include SchoolProfileHeader
      include Footer
    end
  end
end
