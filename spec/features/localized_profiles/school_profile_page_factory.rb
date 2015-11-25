require 'spec_helper'

class SchoolProfilePageFactory
  attr_reader :page

  def initialize(page_name = 'Overview')
    page_name ||= 'Overview'
    @page = FactoryGirl.create(:page, name: page_name)
  end

  def with_facebook_like_box_module
    facebook_section = FactoryGirl.create(
      :category_placement,
      title: 'Facebook',
      page: page,
      layout: 'section'
    )

    facebook_module = FactoryGirl.create(
      :category_placement,
      page: page,
      layout: 'facebook_like_box',
      parent: facebook_section
    )

    return self
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

  def with_state_test_guide_module
    state_test_guide_section = FactoryGirl.create(
      :category_placement,
      title: 'State Test Guide',
      page: page,
      layout: 'state_test_guide'
    )

    return self
  end


end
