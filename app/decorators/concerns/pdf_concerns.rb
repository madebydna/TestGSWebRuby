#encoding: utf-8

module PdfConcerns

  SCHOOL_CACHE_KEYS = %w(characteristics ratings esp_responses reviews_snapshot)


  # icon_path = 'app/assets/images/pyoc/map_icons/'

  ZIPCODE_TO_ICON_MAPPING = {

      '46077' => 'Indy_map_1.png',
      '46107' => 'Indy_map_10.png',
      '46113' => 'Indy_map_7.png',
      '46163' => 'Indy_map_9.png',
      '46201' => 'Indy_map_5.png',
      '46202' => 'Indy_map_5.png',
      '46203' => 'Indy_map_5.png',
      '46204' => 'Indy_map_5.png',
      '46205' => 'Indy_map_5.png',
      '46208' => 'Indy_map_5.png',
      '46214' => 'Indy_map_4.png',
      '46216' => 'Indy_map_3.png',
      '46217' => 'Indy_map_8.png',
      '46218' => 'Indy_map_5.png',
      '46219' => 'Indy_map_6.png',
      '46220' => 'Indy_map_2.png',
      '46221' => 'Indy_map_7.png',
      '46222' => 'Indy_map_5.png',
      '46224' => 'Indy_map_4.png',
      '46225' => 'Indy_map_5.png',
      '46226' => 'Indy_map_3.png',
      '46227' => 'Indy_map_8.png',
      '46228' => 'Indy_map_2.png',
      '46229' => 'Indy_map_6.png',
      '46231' => 'Indy_map_7.png',
      '46234' => 'Indy_map_4.png',
      '46235' => 'Indy_map_3.png',
      '46236' => 'Indy_map_3.png',
      '46237' => 'Indy_map_8.png',
      '46239' => 'Indy_map_9.png',
      '46240' => 'Indy_map_2.png',
      '46241' => 'Indy_map_7.png',
      '46250' => 'Indy_map_2.png',
      '46254' => 'Indy_map_1.png',
      '46256' => 'Indy_map_3.png',
      '46259' => 'Indy_map_9.png',
      '46260' => 'Indy_map_2.png',
      '46268' => 'Indy_map_1.png',
      '46278' => 'Indy_map_1.png',
      '53110' => 'Mke_map_6.png',
      '53129' => 'Mke_map_5.png',
      '53130' => 'Mke_map_5.png',
      '53202' => 'Mke_map_4.png',
      '53203' => 'Mke_map_4.png',
      '53204' => 'Mke_map_6.png',
      '53205' => 'Mke_map_4.png',
      '53206' => 'Mke_map_4.png',
      '53207' => 'Mke_map_6.png',
      '53208' => 'Mke_map_3.png',
      '53209' => 'Mke_map_2.png',
      '53210' => 'Mke_map_3.png',
      '53211' => 'Mke_map_4.png',
      '53212' => 'Mke_map_4.png',
      '53213' => 'Mke_map_3.png',
      '53214' => 'Mke_map_5.png',
      '53215' => 'Mke_map_6.png',
      '53216' => 'Mke_map_3.png',
      '53217' => 'Mke_map_2.png',
      '53218' => 'Mke_map_1.png',
      '53219' => 'Mke_map_5.png',
      '53220' => 'Mke_map_5.png',
      '53221' => 'Mke_map_6.png',
      '53222' => 'Mke_map_3.png',
      '53223' => 'Mke_map_1.png',
      '53224' => 'Mke_map_1.png',
      '53225' => 'Mke_map_1.png',
      '53226' => 'Mke_map_3.png',
      '53227' => 'Mke_map_5.png',
      '53228' => 'Mke_map_5.png',
      '53233' => 'Mke_map_4.png',
      '53235' => 'Mke_map_6.png',
      '73078' => 'OKC_map_01.png',
      '73099' => 'OKC_map_01.png',
      '73064' => 'OKC_map_01.png',
      '73063' => 'OKC_map_01.png',
      '73090' => 'OKC_map_01.png',
      '73054' => 'OKC_map_02.png',
      '73025' => 'OKC_map_02.png',
      '73012' => 'OKC_map_02.png',
      '73013' => 'OKC_map_02.png',
      '73003' => 'OKC_map_02.png',
      '73034' => 'OKC_map_02.png',
      '73007' => 'OKC_map_02.png',
      '73049' => 'OKC_map_03.png',
      '73084' => 'OKC_map_03.png',
      '73020' => 'OKC_map_03.png',
      '73130' => 'OKC_map_03.png',
      '73150' => 'OKC_map_03.png',
      '73045' => 'OKC_map_03.png',
      '74851' => 'OKC_map_03.png',
      '74857' => 'OKC_map_03.png',
      '73110' => 'OKC_map_03.png',
      '73115' => 'OKC_map_03.png',
      '73135' => 'OKC_map_03.png',
      '73145' => 'OKC_map_03.png',
      '73173' => 'OKC_map_04.png',
      '73170' => 'OKC_map_04.png',
      '73065' => 'OKC_map_04.png',
      '73072' => 'OKC_map_04.png',
      '73160' => 'OKC_map_04.png',
      '73069' => 'OKC_map_04.png',
      '73165' => 'OKC_map_04.png',
      '73071' => 'OKC_map_04.png',
      '73026' => 'OKC_map_04.png',
      '73068' => 'OKC_map_04.png',
      '73142' => 'OKC_map_05.png',
      '73134' => 'OKC_map_05.png',
      '73162' => 'OKC_map_05.png',
      '73120' => 'OKC_map_05.png',
      '73114' => 'OKC_map_05.png',
      '73131' => 'OKC_map_05.png',
      '73151' => 'OKC_map_05.png',
      '73132' => 'OKC_map_05.png',
      '73116' => 'OKC_map_05.png',
      '73105' => 'OKC_map_05.png',
      '73111' => 'OKC_map_05.png',
      '73121' => 'OKC_map_05.png',
      '73141' => 'OKC_map_05.png',
      '73008' => 'OKC_map_05.png',
      '73122' => 'OKC_map_05.png',
      '73112' => 'OKC_map_05.png',
      '73118' => 'OKC_map_05.png',
      '73127' => 'OKC_map_05.png',
      '73107' => 'OKC_map_05.png',
      '73106' => 'OKC_map_05.png',
      '73103' => 'OKC_map_05.png',
      '73102' => 'OKC_map_05.png',
      '73104' => 'OKC_map_05.png',
      '73117' => 'OKC_map_05.png',
      '73128' => 'OKC_map_05.png',
      '73108' => 'OKC_map_05.png',
      '73109' => 'OKC_map_05.png',
      '73129' => 'OKC_map_05.png',
      '73179' => 'OKC_map_05.png',
      '73119' => 'OKC_map_05.png',
      '73169' => 'OKC_map_05.png',
      '73159' => 'OKC_map_05.png',
      '73139' => 'OKC_map_05.png',
      '73149' => 'OKC_map_05.png',
  }

  ENGLISH_TO_SPANISH_SCHOOL_TYPE_MAPPING = {
      'Private' => 'Privada',
      'Public district' => 'Pública',
      'Public charter' => 'Charter Pública'

  }

  ENGLISH_TO_SPANISH_DIVERSITY_MAPPING = {
      'African-American' => 'Afroamericano/Negro',
      'American Indian' => 'Amerindio/Nativo Americano',
      'American Indian/Alaskan Native' => 'Amerindio/Nativo Americano',
      'Asian' => 'Asiático',
      'Asian/Pacific Islander' => 'Asiático',
      'Black' => 'Afroamericano/Negro',
      'Black, not Hispanic' => 'Afroamericano/Negro',
      'Hispanic' => 'Hispano/Latino',
      'Multiracial' => 'De raza multiple/otro',
      'Native American or Native' => 'Amerindio/Nativo Americano',
      'Native American or Native Alaskan' => 'Amerindio/Nativo Americano',
      'Native Hawaiian' => 'Nativo Hawaiiano',
      'Native Hawaiian or Pacific Islander' => 'Nativo Hawaiiano',
      'Native Hawaiian or Other Pacific Islander' => 'Nativo Hawaiiano',
      'White' => 'Caucásico/Blanco',
      'White, not Hispanic' => 'Caucásico/Blanco'

  }

  ENGLISH_TO_SPANISH_ELL_SPED_MAPPING = {
      'None' => 'Ninguno',
      'Basic' => 'Básicos',
      'Moderate' => 'Moderado',
      'Intensive' => 'Intensivo'
  }


  ENGLISH_TO_SPANISH_DEADLINE_MAPPING = {
      'Contact school' => 'Contacta la escuela',
      'Rolling deadline' => 'Abierta todo el año',
      'n/a' => 'n/a'
  }

  ENGLISH_TO_SPANISH_RATINGS_MAPPING = {
      'Excellent Schools Detroit Rating' => 'Calificación ESD',
      'State Rating' => 'Calificación Estado',
      'Great Start to Quality preschool rating' => 'Calificación prescolar',
      'QRIS Preschool rating' => 'Calificación prescolar',
      'Level 0' => 'Nivel 0',
      'Level 1' => 'Nivel 1',
      'Level 2' => 'Nivel 2',
      'Level 3' => 'Nivel 3',
      'Level 4' => 'Nivel 4',
  }

  COLLECTION_ID_TO_FOOTER_MAPPING = {
      1 => 'Detroit School Guide 2015-2016',
      2 => 'Milwaukee School Guide 2015-2016',
      3 => 'Indianapolis School Guide 2015-2016',
      12 => 'Oklahoma City School Guide 2016-2017',

  }

  COLLECTION_ID_TO_FOOTER_MAPPING_SPANISH = {
      1 => 'Listado de Escuelas de Detroit 2015-2016',
      2 => 'Listado de Escuelas de Milwaukee 2015-2016',
      3 => 'Listado de Escuelas de Indianapolis 2015-2016',
      12 => 'Listado de Escuelas de Oklahoma City 2016-2017',
  }

  COLLECTION_ID_LANDING_PAGE_MAPPING = {
      1 => 'www.greatschoolsdetroit.org',
      2 => 'www.greatschoolsmilwaukee.org',
      3 => 'www.greatschools.org/indianapolis',
      12 => 'www.greatschoolsoklahomacity.org',
  }

  # Map_icon_to_school_name_mapping = {'no_map_icon' => []}

  def which_school_type(type)
    ENGLISH_TO_SPANISH_SCHOOL_TYPE_MAPPING[school_type_display(type)]
  end

  def which_ethnicity_key_mapping(data)
    ethnicity_data = data.map do |k, v|
      [ENGLISH_TO_SPANISH_DIVERSITY_MAPPING[k], v]
    end
  end

  def which_ell_mapping
    ENGLISH_TO_SPANISH_ELL_SPED_MAPPING[school_cache.ell]
  end

  def which_sped_mapping
    ENGLISH_TO_SPANISH_ELL_SPED_MAPPING[school_cache.sped]
  end

  def which_deadline_mapping
    ENGLISH_TO_SPANISH_DEADLINE_MAPPING[school_cache.deadline]
  end

  def which_rating_mapping(data)
    ENGLISH_TO_SPANISH_RATINGS_MAPPING[data]
  end

  # def find_schools_to_be_printed(state,collection_id,is_high_school,is_k8,is_pk8,added_schools,removed_schools,school_id1,school_id2,school_id3,school_id4,is_location_index,is_performance_index)
  def find_schools_to_be_printed(state, opts = {})
    collection_id = opts[:collection_id]
    is_high_school = opts[:is_high_school]
    is_k8 = opts[:is_k8]
    is_pk8 = opts[:is_pk8]
    added_schools = opts[:added_schools]
    removed_schools = opts[:removed_schools]
    school_id1 = opts[:id1]
    school_id2 = opts[:id2]
    school_id3 = opts[:id3]
    school_id4 = opts[:id4]
    grade_level_for_index=opts[:grade_level_for_index]

    db_schools = []

    if state.present?
      if collection_id.present? && collection_id>0 && is_high_school
        db_schools = School.for_collection_ordered_by_name(state, collection_id)
        db_schools.select!(&:includes_highschool?)

      elsif collection_id.present? && collection_id>0 && is_pk8
        db_schools = School.for_collection_ordered_by_name(state, collection_id)
        db_schools.select!(&:pk8?)
      elsif  collection_id.present? && collection_id>0 && is_k8
        db_schools = School.for_collection_ordered_by_name(state, collection_id)
        db_schools.select!(&:k8?)
      elsif collection_id.present? && collection_id>0 && !is_k8 && !is_high_school && !is_pk8 & !grade_level_for_index
        db_schools = School.for_collection_ordered_by_name(state, collection_id)
      elsif collection_id.present? && collection_id>0 && !is_k8 && !is_high_school && !is_pk8 & grade_level_for_index
        db_schools = School.for_collection_ordered_by_name(state, collection_id)
        if grade_level_for_index.present? && grade_level_for_index.is_a?(Array)
          db_schools.select! do |school|
            school.includes_level_code?(grade_level_for_index)
          end
        elsif grade_level_for_index.present? && !grade_level_for_index.is_a?(Array)
          db_schools.select! do |school|
            school.includes_level_code?(grade_level_for_index.split(" "))
          end
        end
      elsif   collection_id==0 && (!school_id1.present? || !school_id2.present? || !school_id3.present? || !school_id4.present?)
        db_schools = School.on_db(state).active.order(name: :asc).to_a
      elsif   state.present? && (school_id1.present? || school_id2.present? || school_id3.present? || school_id4.present?)
        db_schools = School.for_states_and_ids([state, state, state, state], [school_id1, school_id2, school_id3, school_id4])
      end

      # Add schools
      if added_schools.present?
        schools_to_be_added = added_schools.split(',')
        db_schools += School.on_db(state).where(id: schools_to_be_added).all
        db_schools.sort! { |a, b| a.name <=> b.name }
      end

      # Remove schools
      if removed_schools.present?
        schools_to_be_removed = removed_schools.split(',')
        db_schools -= School.on_db(state).where(id: schools_to_be_removed).all
        db_schools.sort! { |a, b| a.name <=> b.name }
      end
    end
    db_schools
  end


  def prep_data_for_pdf(db_schools)
    query = SchoolCacheQuery.new.include_cache_keys(SCHOOL_CACHE_KEYS)
    db_schools.each do |school|
      query = query.include_schools(school.state, school.id)
    end
    query_results = query.query

    school_cache_results = SchoolCacheResults.new(SCHOOL_CACHE_KEYS, query_results)
    schools_with_cache_results= school_cache_results.decorate_schools(db_schools)
    schools_decorated_with_cache_results = schools_with_cache_results.map do |school|
      PyocDecorator.decorate(school)
    end
  end

  def which_icon
    icon_path = 'app/assets/images/pyoc/map_icons/'
    zip = zipcode.to_s.strip
    ZIPCODE_TO_ICON_MAPPING[zip].present? ? icon_path + ZIPCODE_TO_ICON_MAPPING[zip] : 'N/A'
  end

  def which_footer(collection_id, is_spanish)

    if is_spanish
      COLLECTION_ID_TO_FOOTER_MAPPING_SPANISH[collection_id].nil? ? 'Listado de Escuelas' : COLLECTION_ID_TO_FOOTER_MAPPING_SPANISH[collection_id]
    else
      COLLECTION_ID_TO_FOOTER_MAPPING[collection_id].nil? ? 'School Guide' : COLLECTION_ID_TO_FOOTER_MAPPING[collection_id]
    end
  end

  def which_landing_page(collection_id)
    COLLECTION_ID_LANDING_PAGE_MAPPING[collection_id].nil? ? 'www.greatschools.org' : COLLECTION_ID_LANDING_PAGE_MAPPING[collection_id]
  end

  def find_above_avg_schools_for_index(schools_decorated_with_cache_results, rating_type)
    above_avg = []
    above_avg_ratings = ['8', '9', '10']
    schools_decorated_with_cache_results.each do |school|
      school_cache = school
      if  rating_type == 'overall_gs_rating' && above_avg_ratings.include?(school.school_cache.overall_gs_rating)
        above_avg.push(school_cache.name)
      end
      if rating_type == 'test_score_rating' && above_avg_ratings.include?(school.school_cache.test_scores_rating.to_s)
        above_avg.push(school_cache.name)
      end
      if rating_type == 'student_growth_rating' && above_avg_ratings.include?(school.school_cache.student_growth_rating.to_s)
        above_avg.push(school_cache.name)
      end
      if rating_type == 'college_readiness_rating' && above_avg_ratings.include?(school.school_cache.college_readiness_rating.to_s)
        above_avg.push(school_cache.name)
      end
    end
    above_avg
  end

  def find_schools_by_location_for_index(schools_decorated_with_cache_results)

    map_icon_to_school_name_mapping = {'no_map_icon' => []}

    schools_decorated_with_cache_results.each do |school|
      school_cache = school

      zipcode_mapping = ZIPCODE_TO_ICON_MAPPING[school_cache.zipcode]

      if map_icon_to_school_name_mapping.has_key? zipcode_mapping
        map_icon_to_school_name_mapping[zipcode_mapping] << school.name
      elsif  zipcode_mapping.nil?
        map_icon_to_school_name_mapping['no_map_icon'] << school.name
      else
        map_icon_to_school_name_mapping[zipcode_mapping] = [].push(school.name)
      end
    end

    map_icon_to_school_name_mapping
  end

  def school_type_display(type)
    school_types_map = {
        charter: 'Public charter',
        public: 'Public district',
        private: 'Private'
    }
    school_types_map[type.to_s.downcase.to_sym]
  end
end
