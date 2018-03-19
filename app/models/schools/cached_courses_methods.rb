# frozen_string_literal: true

module CachedCoursesMethods

  def courses
    cache_data['courses'] || {}
  end

  def max_source_date_valid
    @_max_source_date_valid ||= begin
      all_courses_objs = courses.values.map do |array_of_hashes|
        array_of_hashes.map { |hash| GsdataCaching::GsDataValue.from_hash(hash) }
      end.flatten.extend(GsdataCaching::GsDataValue::CollectionMethods)
      most_recent = all_courses_objs.most_recent
      most_recent&.source_date_valid
    end
  end
end
