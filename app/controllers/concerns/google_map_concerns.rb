module GoogleMapConcerns
  extend ActiveSupport::Concern

  def mapping_points_through_gon
    gon.map_points = @map_schools.map do |school|
      begin
        map_points = SchoolSearchResultDecorator.decorate(school).google_map_data_point
        map_points[:communityRatingStars] = school.community_rating.nil? ? '' : (draw_stars_16 school.community_rating)
        map_points[:profileUrl] = "/#{@state[:long]}/city/#{school.id}-school"
        map_points[:reviewUrl] = "#{map_points[:profileUrl]}/reviews"
        map_points[:zillowUrl] = zillow_url(school)
        school.latitude.nil? ? next : map_points[:lat] = school.latitude
        school.longitude.nil? ? next : map_points[:lng] = school.longitude
        map_points[:numReviews] = school.review_count.nil? ? 0 : school.review_count
        map_points[:zIndex] = -1 unless school.on_page
        map_points
      rescue NoMethodError => e
        puts e.message
        puts 'School Not Added as a Map Pin'
        nil
      else
        map_points
      end
    end.compact
  end

  def mapping_points_through_gon_from_db
    gon.map_points = @map_schools.map do |school|
      map_points = {}
      map_points[:name] = school.name
      map_points[:id] = school.id
      map_points[:preschools] = school.preschool?
      map_points[:gsRating] = school.great_schools_rating
      map_points[:on_page] = true
      school.lat.nil? ? next : map_points[:lat] = school.lat
      school.lon.nil? ? next : map_points[:lng] = school.lon
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