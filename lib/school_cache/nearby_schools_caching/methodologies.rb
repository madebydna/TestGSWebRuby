class NearbySchoolsCaching::Methodologies
  def self.results(school, opts)
    schools = self.schools(school, opts)
    NearbySchoolsCaching::QueryResultDecorator.decorate_list(schools).map(&:to_h)
  end

  def self.schools(*args)
    raise NotImplementedError, 'All NearbySchoolsCaching::Methodologies must
                                implement #school and it must return an array
                                of School objects.'
  end
end
