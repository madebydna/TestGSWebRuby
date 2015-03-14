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

end