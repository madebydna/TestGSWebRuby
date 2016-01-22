module SchoolProfileHeader
  def self.included(page_class)
    page_class.class_eval do
      section :school_profile_header, '.profile-dark-header' do
      end
    end
  end
end