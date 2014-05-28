class NearbySchoolDecorator < SchoolProfileDecorator
  decorates :school
  delegate_all

  def link_to_overview(*args, &blk)
    h.link_to h.school_path(school), *args, &blk
  end

  def photo(width, height)
    link_to_overview do
      super
    end
  end

end