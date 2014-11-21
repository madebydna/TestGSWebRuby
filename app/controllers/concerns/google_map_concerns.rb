module GoogleMapConcerns
  extend ActiveSupport::Concern

  def mapping_points_through_gon
    gon.map_points = @map_schools.map do |school|
      begin
        map_points = SchoolSearchResultDecorator.decorate(school).google_map_data_point
        map_points[:communityRatingStars] = school.community_rating.nil? ? '' : school.community_rating#(draw_stars_16 school.community_rating)
        map_points[:profileUrl] = (school.profile_path.present?) ? school.profile_path : "/#{@state[:long]}/city/#{school.id}-school"
        map_points[:reviewUrl] = "#{map_points[:profileUrl]}/reviews"
        map_points[:zillowUrl] = zillow_url(school)
        school.latitude.nil? ? next : map_points[:lat] = school.latitude
        school.longitude.nil? ? next : map_points[:lng] = school.longitude
        map_points[:numReviews] = (school.review_count.nil? || school.community_rating.nil?) ? 0 : school.review_count
        map_points[:zIndex] = -1 unless school.on_page
        map_points
      rescue NoMethodError => e
        Rails.logger.error "School not added as map pin because of error: #{e}"
        nil
      else
        map_points
      end
    end.compact
  end

  def mapping_points_through_gon_from_db(schools,options_hash={})
    gon.map_points ||= []
    gon.map_points += schools.map do |school|
      decorated_school = SchoolMapsDecorator.decorate(school)
      map_points = {}
      map_points[:name] = decorated_school.name
      map_points[:id] = decorated_school.id
      map_points[:preschools] = decorated_school.preschool?
      map_points[:gsRating] = decorated_school.great_schools_rating
      map_points[:on_page] = !options_hash[:on_page].nil? ? options_hash[:on_page] : true
      map_points[:zIndex] = -1 unless map_points[:on_page]

      if options_hash[:show_bubble]
        overview_url = school_path(school)
        map_points[:profileUrl] =  overview_url.present? ? overview_url : "/#{@state[:long]}/city/#{school.id}-school"
        map_points[:reviewUrl] = "#{map_points[:profileUrl]}/reviews"
        map_points[:street] = decorated_school.street
        map_points[:city] = decorated_school.city
        map_points[:state] = decorated_school.state
        map_points[:zillowUrl] = zillow_url(school)
        map_points[:gradeRange] = decorated_school.grade_range
        map_points[:schoolType] = decorated_school.school_type
        map_points[:numReviews] = (decorated_school.review_count.nil? || decorated_school.community_rating.nil?) ? 0 : decorated_school.review_count
        map_points[:communityRatingStars] = decorated_school.community_rating.nil? ? '' : decorated_school.community_rating#(draw_stars_16 school.community_rating)
      end

      decorated_school.lat.nil? ? next : map_points[:lat] = decorated_school.lat
      decorated_school.lon.nil? ? next : map_points[:lng] = decorated_school.lon
      map_points
    end.compact
  end

  def assign_sprite_files_though_gon
    sprite_files = {}
    sprite_files['imageUrlOffPage'] = view_context.image_path('icons/140710-10x10_dots_icons.png')
    sprite_files['imageUrlOnPage'] = view_context.image_path('icons/140725-29x40_pins.png')

    gon.sprite_files = sprite_files

  end



end