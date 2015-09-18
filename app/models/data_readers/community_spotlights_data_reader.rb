class CommunitySpotlightsDataReader < SchoolProfileDataReader

  def data_for_category(category)
    school.collections.select { |collection| collection.has_spotlight? }
  end
end
