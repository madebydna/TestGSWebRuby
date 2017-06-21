class NearbySchoolsCaching::QueryResultDecorator < Draper::Decorator
  decorates :school
  delegate_all

  include ApplicationHelper
  include SchoolHelper
  include GradeLevelConcerns
  include SchoolPhotoConcerns

  def to_h
    {
              city: city,
          distance: try(:distance),
         gs_rating: gs_rating,
                id: id,
             level: process_level,
       methodology: methodology,
              name: name,
      school_media: school_media,
             state: state,
              type: school_type_display(type),
    }
  end

  def self.decorate_list(schools)
    [*schools].map { |s| self.decorate(s) }
  end

  protected

  def gs_rating
    great_schools_rating.presence || 'nr'
  end

  def school_type
    school_type_display(type)
  end

  def school_media
    uploaded_photo(70)
  end
end
