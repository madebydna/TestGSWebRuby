class CompareSchoolsController < ApplicationController
  include GoogleMapConcerns
  include CompareSchoolsConcerns

  def show
    @params_schools = params[:school_ids].nil? ? [] : params[:school_ids].split(',').uniq
    @state = params[:state] || :de

    @school_compare_config = SchoolCompareConfig.new(compare_schools_list_mapping)

    gon.pagename = 'CompareSchoolsPage'

    prepare_schools
    prepare_map
  end

  def prepare_schools
    @schools = decorated_schools
    prep_school_ethnicity_data!
  end

  def prepare_map
    @map_schools = @schools
    mapping_points_through_gon_from_db
    assign_sprite_files_though_gon
  end

end