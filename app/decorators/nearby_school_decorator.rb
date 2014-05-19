class NearbySchoolDecorator < SchoolProfileDecorator
  decorates :school
  delegate_all

  def link_to_overview(&blk)
    h.link_to h.school_path(school), &blk
  end

  def photo(width, height)
    link_to_overview do
      super
    end
  end

end