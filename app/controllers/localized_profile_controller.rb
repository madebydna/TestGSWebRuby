class LocalizedProfileController < ApplicationController
  protect_from_forgery

  include LocalizationConcerns
  include OmnitureConcerns

  before_filter :require_state, :require_school
  before_filter :redirect_to_canonical_url, only: [:overview, :quality, :details, :reviews]
  before_filter :read_config_for_page, except: :reviews
  before_filter :init_page, :set_header_data
  before_filter :store_location, only: [:overview, :quality, :details, :reviews]
  before_filter :set_last_school_visited, only: [:overview, :quality, :details, :reviews]
  before_filter :set_hub_cookies
  before_filter :set_seo_meta_tags
  before_filter :set_last_modified_date

  layout 'application'

  def overview
    #Set the pagename before setting other omniture props.
    gon.omniture_pagename = 'GS:SchoolProfiles:Overview'
    set_omniture_data(gon.omniture_pagename)
    @canonical_url = school_url(@school)
  end

  def quality
    #Set the pagename before setting other omniture props.
    gon.omniture_pagename = 'GS:SchoolProfiles:Quality'
    set_omniture_data(gon.omniture_pagename)
    @canonical_url = school_quality_url(@school)
  end

  def details
    #Set the pagename before setting other omniture props.
    gon.omniture_pagename = 'GS:SchoolProfiles:Details'
    set_omniture_data(gon.omniture_pagename)
    @canonical_url = school_details_url(@school)
  end

  def reviews
    #Set the pagename before setting other omniture props.
    gon.omniture_pagename = 'GS:SchoolProfiles:Reviews'
    @canonical_url = school_reviews_url(@school)

    @school_reviews = @school.reviews_filter quantity_to_return: 10

    @review_offset = 0
    @review_limit = 10
  end

  #protected

  def set_omniture_data(page_name)
    set_omniture_hier_for_new_profiles
    set_omniture_data_for_school(page_name)
    set_omniture_data_for_user_request

    read_omniture_data_from_session
  end

  def init_page
    @google_signed_image = GoogleSignedImages.new @school, gon
    gon.pagename = configured_page_name
    @cookiedough = SessionCacheCookie.new cookies[:SESSION_CACHE]
  end

  def read_config_for_page
    @page_config = PageConfig.new configured_page_name, @school
  end

  def set_header_data
    @header_metadata = @school.school_metadata
    @school_reviews_global = SchoolReviews.set_reviews_objects @school
  end

  # get Page name in PageConfig, based on current controller action
  def configured_page_name
    # i.e. 'School stats' in page config means this controller needs a 'school_stats' action
    action_name.gsub(' ', '_').capitalize
  end

  # requires that @school has already been obtained from db
  def redirect_to_canonical_url
    helper_name = 'school_'
    helper_name << "#{action_name}_" if action_name != 'overview'
    helper_name << 'path'

    canonical_path = self.send helper_name.to_sym, @school

    redirect_to canonical_path if canonical_path != request.path + '/'
  end

  def set_seo_meta_tags
    set_meta_tags :title => seo_meta_tags_title,
                  :description => seo_meta_tags_description,
                  :keywords =>  seo_meta_tags_keywords
  end

  # title logic
  # schoolName+' - '+city+', '+stateNameFull+' - '+stateAbbreviation+' - School '+PageName
  def seo_meta_tags_title
    return_title_str = ''
    return_title_str << @school.name + ' - '
     if @school.state.downcase == 'dc'
       return_title_str << 'Washington, DC'
     else
       return_title_str << @school.city + ', ' + @school.state_name.capitalize + ' - ' + @school.state
     end
     return_title_str << ' - School ' + action_name

  end

  def seo_meta_tags_description
    return_description_str = ''
    state_name_local = ''
    return_description_str << @school.name
    state_name_local = @school.state_name.capitalize
    if @school.state.downcase == 'dc'
      state_name_local = 'Washington DC'
    end
    if @school.preschool?
      return_description_str << ' in ' + @school.city + ', ' + state_name_local + ' (' + @school.state + ')'
      return_description_str << ". Read parent reviews and get the scoop on the school environment, teachers,"
      return_description_str << " students, programs and services available from this preschool."
    else
      return_description_str << ' located in ' + @school.city + ', ' + state_name_local + ' - ' + @school.state
      return_description_str << '. Find ' +  @school.name + ' test scores, student-teacher ratio, parent reviews and teacher stats.'
    end
    return_description_str
  end

  def seo_meta_tags_keywords
    name = @school.name.clone
    return_keywords_str  =''
    return_keywords_str << name
    if @school.preschool?
      if name.downcase.end_with? 'pre-school'
        return_keywords_str << ', ' + name.downcase.gsub(/\ (pre-school)$/, ' preschool').gs_capitalize_words!
      elsif name.downcase.end_with? 'preschool'
        return_keywords_str << ', ' + name.downcase.gsub(/\ (preschool)$/, ' pre-school').gs_capitalize_words!
      end
    else
      return_keywords_str << ', ' + name + ' ' + @school.city
      return_keywords_str << ', ' + name + ' ' + @school.city + ' ' +  @school.state_name.capitalize
      return_keywords_str << ', ' + name + ' ' + @school.city + ' ' + @school.state
      return_keywords_str << ', ' + name + ' ' + @school.state_name.capitalize
      return_keywords_str << ', ' + name + ' ' + action_name
    end
    return_keywords_str
  end

  def set_last_modified_date
    # TODO: smarter way of calculating profile's last modified date. Java code takes greater of school modified and
    # date of latest non-principal review
    @last_modified_date = @school.modified
  end

end
