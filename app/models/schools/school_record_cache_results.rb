class SchoolRecordCacheResults < SchoolCacheResults
  def decorate_schools(schools)
    [*schools].map do |school|
      decorated = SchoolCacheDecorator.new(school, @school_data[[school.state.upcase, school.school_id]] || {})
      @cache_keys.each do |key|
        if module_for_key(key)
          decorated.send(:extend, (module_for_key(key)))
        end
      end
      decorated
    end
  end
end