class CompareSchoolsController < ApplicationController
  # include GoogleMapConcerns
  # include CompareSchoolsConcerns
  # include SearchHelper
  # include SchoolHelper
  # include DataDisplayHelper
  include AdvertisingConcerns
  include PageAnalytics
  include CommunityConcerns

  layout "application"
  before_filter :redirect_unless_schoolId_and_state

  def show


    # LEGACY################################################
    # require_state
    # set_login_redirect
    # @params_schools = params[:school_ids].nil? ? [] : params[:school_ids].split(',').uniq
    # @state = state_param
    #
    #
    # gon.pagename = 'CompareSchoolsPage'
    # page_title = 'Compare Schools'
    # gon.pageTitle = page_title
    #
    # prepare_schools
    # prepare_map
    # set_back_to_search_results_instance_variable
    #
    # set_meta_tags title: page_title,
    #               description:'Compare schools to find the right school for your family',
    #               robots: 'noindex'
    # set_omniture_data
    # set_data_layer_variables
    #
    # @school_compare_config = SchoolCompareConfig.new(compare_schools_list_mapping)
  end

  private

  def state
    params[:state]
  end

  def school_id
    params[:schoolId]
  end

  def sort
    params[:sort]
  end

  def redirect_unless_schoolId_and_state
    redirect_to :back unless
  end

  # def prepare_schools
  #   @schools = decorated_schools
  #   prep_school_ethnicity_data!
  #   prep_school_ratings!
  # end
  #
  # def prepare_map
  #   mapping_points_through_gon_from_db(@schools)
  #   assign_sprite_files_though_gon
  # end
  #
  # def set_omniture_data
  #   gon.omniture_pagename = "GS:Compare"
  #   gon.omniture_hier1 = "Compare"
  #   set_omniture_data_for_user_request
  #   gon.omniture_channel = @state.try(:upcase) if @state
  # end
  #
  # def set_data_layer_variables
  #   state = @state.try(:upcase) if @state
  #
  #   data_layer_gon_hash.merge!(
  #     {
  #       'page_name' => 'GS:Compare',
  #       'State' => state,
  #     }
  #   )
  # end

  def default_extras
    %w(summary_rating enrollment review_summary students_per_teacher)
  end
end
