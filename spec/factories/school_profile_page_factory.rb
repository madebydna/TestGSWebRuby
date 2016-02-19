class SchoolProfilePageFactory
  attr_reader :page

  def initialize(page_name = 'Overview')
    page_names = %w[Overview Reviews Quality Details]
    page_name ||= 'Overview'
    @page = FactoryGirl.create(:page, name: page_name)
    # Create rows for the other pages as well
    (page_names - Array.wrap(page_name)).each do |page_name|
      FactoryGirl.create(:page, name: page_name)
    end
  end

  def with_snapshot_module
    snapshot_category = FactoryGirl.create(:category, name: 'Snapshot', source: 'snapshot')

    snapshot_category_data = FactoryGirl.create(:category_data, category: snapshot_category, response_key: 'enrollment', source: 'census_data_points', label: 'Students enrolled')

    snapshot_category_placement = FactoryGirl.create(
      :category_placement,
      category: snapshot_category,
      title: 'Snapshot',
      page: page,
      layout: 'snapshot'
    )

    return self
  end

  def with_gs_rating_snapshot_module
    FactoryGirl.create(
        :category_placement,
        title: 'Ratings snapshot',
        page: page,
        layout: 'snapshot_ratings'
    )
    return self
  end

  def with_reviews_snapshot_module
    FactoryGirl.create(
      :category_placement,
      title: 'Ratings snapshot',
      page: page,
      layout: 'snapshot_reviews'
    )
    return self
  end


  def with_contact_this_school_section
    contact_section = FactoryGirl.create(
        :category_placement,
        title: 'Contact this school',
        page: page,
        layout: 'section'
    )

    FactoryGirl.create(
        :category_placement,
        title: 'School contact info module',
        page: page,
        layout: 'school_contact_info',
        parent: contact_section
    )



    return self
    return self
  end
  def with_state_test_guide_module
    state_test_guide_section = FactoryGirl.create(
      :category_placement,
      title: 'State Test Guide',
      page: page,
      layout: 'state_test_guide'
    )

    return self
  end

  def with_reviews_section_on_overview
    FactoryGirl.create(
      :category_placement,
      title: 'Reviews',
      page: page,
      layout: 'reviews_overview'
    )

    return self
  end

  def with_media_gallery
    FactoryGirl.create(
      :category_placement,
      title: 'Media Gallery',
      page: page,
      layout: 'lightbox_overview'
    )

    return self
  end

  def with_zillow_module
    FactoryGirl.create(
        :category_placement,
        title: 'Nearby homes and rentals',
        page: page,
        layout: 'zillow'
    )

    return self
  end

  def with_quick_links
    FactoryGirl.create(
        :category_placement,
        title: 'Quick links',
        page: page,
        layout: 'quick_links'
    )

    return self
  end

end
