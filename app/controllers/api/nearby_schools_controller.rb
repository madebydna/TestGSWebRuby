class Api::NearbySchoolsController < ApplicationController
  DEFAULT_LIMIT = 3
  MAX_LIMIT = 6

  before_filter :require_school

  def show
    array_of_nearby_school_hashes =
      NearbySchoolsCaching::Methodologies::ClosestSchools.results(
        school,
        limit: limit,
        offset: params[:offset].to_i
      )
    if array_of_nearby_school_hashes.present?
      add_review_data_to_nearby_school_hashes(array_of_nearby_school_hashes)
    end

    @array_of_nearby_school_hashes = array_of_nearby_school_hashes
  end

  protected 

  def add_review_data_to_nearby_school_hashes(hashes)
    school_ids = hashes.map { |h| h[:id] }
    review_datas = Review.average_five_star_rating(school.state, school_ids)
    hashes.each do |hash|
      review_data_for_school = review_datas[hash[:id]]
      hash.merge!(review_data_for_school.to_h) if review_data_for_school
    end
  end

  def limit
    return DEFAULT_LIMIT unless params[:limit]
    [params[:limit].to_i, MAX_LIMIT].min
  end

  def school
    return @_school if defined?(@_school)
    @_school = School.find_by_state_and_id(params[:state], params[:id])
  end

  def require_school
    if school.blank? || !school.active?
      render json: {error: 'School not found'}, status: 404
    end
  end

end
