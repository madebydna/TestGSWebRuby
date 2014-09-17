class CompareSchoolsController < ApplicationController
  include GoogleMapConcerns
  include CompareSchoolsConcerns

  def show
    require_state
    set_login_redirect
    @params_schools = params[:school_ids].nil? ? [] : params[:school_ids].split(',').uniq
    @state = state_param


    gon.pagename = 'CompareSchoolsPage'

    prepare_schools
    prepare_map

    set_meta_tags title:'Compare Schools',
                  description:'Compare schools to find the right school for your family',
                  keywords:'Compare schools, school comparison',
                  robots: 'noindex'
    set_omniture_data

    @school_compare_config = SchoolCompareConfig.new(compare_schools_list_mapping)
  end

  private

  def prepare_schools
    @schools = decorated_schools
    prep_school_ethnicity_data!
    prep_school_ratings!
  end

  def prepare_map
    @map_schools = @schools
    mapping_points_through_gon_from_db
    assign_sprite_files_though_gon
  end

  def set_omniture_data
    gon.omniture_pagename = "GS:Compare"
    gon.omniture_hier1 = "Compare"
    set_omniture_data_for_user_request
    gon.omniture_channel = @state.try(:upcase) if @state

  end
end