class District < ActiveRecord::Base
  self.table_name = 'district'
  include StateSharding
  attr_accessible :not_charter_only, :FIPScounty, :active, :charter_only, :city, :county, :created, :fax, :home_page_url, :lat, :level, :level_code, :lon, :mail_city, :mail_street, :mail_zipcode, :manual_edit_by, :manual_edit_date, :modified, :modifiedBy, :name, :nces_code, :notes, :num_schools, :phone, :state, :state_id, :street, :street_line_2, :type_detail, :zipcentroid, :zipcode
  attr_accessor :cache_data_reader
  has_many :schools

  scope :active, -> { where(active: true) }
  scope :not_charter_only, -> { where(charter_only: 0)}

  def self.find_by_state_and_name(state, name)
    District.on_db(state).where(name: name).active.first rescue nil
  end
  
  def city_record
    City.get_city_by_name_and_state(city, state).first
  end

  def self.find_by_state_and_ids(state, ids = [])
    District.on_db(state.downcase.to_sym).
      where(id: ids).active
  end

  def self.find_by_state_and_city(state, city)
    District.on_db(state.downcase.to_sym).
        where(city: city).active
  end


  def self.ids_by_state(state)
    District.on_db(state.downcase.to_sym).active.order(:id).select(:id).map(&:id)
  end

  def boilerplate_object
    @boilerplate_object ||= DistrictBoilerplate.find_for_district(self).first
  end

  def state_level_boilerplate_object
    @state_level_boilerplate_object ||= DistrictStateLevelBoilerplate.find_for_district(self).first
  end

  def nearby_districts
    nearby_district_objects = 
      NearbyDistrict.find_by_district(self).sorted_by_distance

    neighbor_ids = nearby_district_objects.map(&:neighbor_id)
    districts = District.find_by_state_and_ids(state, neighbor_ids)
    districts.sort_by { |d| neighbor_ids.index(d.id) }
  end

  # Returns numeric value or nil
  # Memoizes its result
  def rating
    @rating ||= (
      district_rating_object = DistrictRating.for_district(self)
      district_rating_object.present? ? district_rating_object.rating : nil
    )
  end

  def schools_by_rating_desc
    @district_schools_by_rating_desc ||= (
      schools = School.within_district(self)

      School.preload_school_metadata!(schools)

      # If the school doesn't exist in the top_school_ids array,
      # then sort it to the end
      schools.sort do |s1, s2|
        if s1.great_schools_rating == s2.great_schools_rating
          0
        elsif s1.great_schools_rating.nil?
          1
        elsif s2.great_schools_rating.nil?
          -1
        else
          s2.great_schools_rating.to_i <=> s1.great_schools_rating.to_i
        end
      end
    )
  end

  def self.by_number_of_schools_desc(state,city)
    District.on_db(state.downcase.to_sym).active.where(city: city.name).order(num_schools: :desc)
  end

  def self.query_distance_function(lat, lon)
    miles_center_of_earth = 3959
    "(
    #{miles_center_of_earth} *
     acos(
       cos(radians(#{lat})) *
       cos( radians( `lat` ) ) *
       cos(radians(`lon`) - radians(#{lon})) +
       sin(radians(#{lat})) *
       sin( radians(`lat`) )
     )
   )".squish
  end

  def test_scores
    @_test_scores ||= Components::ComponentGroups::DistrictTestScoresComponentGroup.new(cache_data_reader: cache_data_reader).to_hash
  end

  def faq_for_academics_module
    @_faq_test_scores ||= SchoolProfiles::Faq.new(cta: I18n.t(:cta, scope: 'lib.equity.faq.race_ethnicity'),
                                     content: I18n.t(:content_html, scope: 'lib.equity.faq.race_ethnicity'),
                                     element_type: 'faq')
  end

  def data_props_for_academics_module
    [
      {
        title: I18n.t('Test scores', scope: 'lib.equity_gsdata'),
        anchor: 'Test_scores',
        data: test_scores
      }
    ]
  end

  def sources_header
    content = ''
    content << '<div class="sourcing">'
    content << '<h1>' + data_label('.title') + '</h1>'
  end

  def data_label(key)
    I18n.t(key.to_sym, scope: 'lib.district', default: I18n.db_t(key, default: key))
  end

  def sources_footer
    '</div>'
  end

  def sources_html(body)
    sources_header + body + sources_footer
  end

  def sources_text(gs_data_values)
    source = gs_data_values.source_name
    flags = flags_for_sources(gs_data_values.all_uniq_flags)
    source_content = I18n.db_t(source, default: source)
    if source_content.present?
      str = '<div>'
      str << '<h4>' + data_label(gs_data_values.data_type) + '</h4>'
      str << "<p>#{Array.wrap(gs_data_values.all_academics).map { |s| data_label(s) }.join(', ')}</p>"
      str << "<p>#{I18n.db_t(gs_data_values.description, default: gs_data_values.description)}</p>"
      if flags.present?
        str << "<p><span class='emphasis'>#{data_label('note')}</span>: #{data_label(flags)}</p>"
      end
      str << "<p><span class='emphasis'>#{data_label('source')}</span>: #{source_content}, #{gs_data_values.year}</p>"
      str << '</div>'
      str
    else
      ''
    end
  end

  def flags_for_sources(flag_array)
    if (flag_array.include?(SchoolProfiles::TestScores::N_TESTED) && flag_array.include?(SchoolProfiles::TestScores::STRAIGHT_AVG))
      SchoolProfiles::TestScores::N_TESTED_AND_STRAIGHT_AVG
    elsif flag_array.include?(SchoolProfiles::TestScores::N_TESTED)
      SchoolProfiles::TestScores::N_TESTED
    elsif flag_array.include?(SchoolProfiles::TestScores::STRAIGHT_AVG)
      SchoolProfiles::TestScores::STRAIGHT_AVG
    end
  end

  def academics_sources
    cache_data_reader
      .recent_test_scores_without_subgroups
      .group_by(&:data_type)
      .values
      .each_with_object('') do |gs_data_values, text|
        text << sources_text(gs_data_values)
    end
  end

  def academics_props(cache_data_reader)
    self.cache_data_reader = cache_data_reader
    {
      title: I18n.t('.academics', scope: 'school_profiles.show'),
      anchor: 'Academics',
      analytics_id: 'Academics',
      subtitle: I18n.t('.Race ethnicity subtitle', scope: 'school_profiles.equity'),
      info_text: nil, #I18n.t('.Race ethnicity tooltip', scope: 'school_profiles.equity')
      icon_classes: I18n.t('.Race ethnicity icon', scope: 'school_profiles.equity'),
      sources: sources_html(academics_sources), #equity.race_ethnicity_sources
      share_content: nil,
      data: data_props_for_academics_module,
      faq: faq_for_academics_module,
      no_data_summary: I18n.t('.Race ethnicity no data', scope: 'school_profiles.equity'),
      qualaroo_module_link: nil
    }
  end

end
