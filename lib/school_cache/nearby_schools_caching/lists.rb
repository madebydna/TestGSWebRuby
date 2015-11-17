class NearbySchoolsCaching::Lists
  def self.results(school, opts)
    schools = self.schools(school, opts)
    NearbySchoolsCaching::QueryResultDecorator.decorate_list(schools).map(&:to_h)
  end

  # All NearbySchoolsCaching::Lists must implement this method and it must
  # return an array of School objects.
  def self.schools
    []
  end
end
