#encoding: utf-8

module PdfConcerns

  SCHOOL_CACHE_KEYS = %w(characteristics ratings esp_responses reviews_snapshot)


  icon_path = 'app/assets/images/pyoc/map_icons/'

  Zipcode_to_icon_mapping = {

      '46077' => icon_path + 'Indy_map_1.png',
      '46107' => icon_path + 'Indy_map_4.png',
      '46113' => icon_path + 'Indy_map_3.png',
      '46163' => icon_path + 'Indy_map_4.png',
      '46201' => icon_path + 'Indy_map_2.png',
      '46202' => icon_path + 'Indy_map_1.png',
      '46203' => icon_path + 'Indy_map_4.png',
      '46204' => icon_path + 'Indy_map_1.png',
      '46205' => icon_path + 'Indy_map_2.png',
      '46208' => icon_path + 'Indy_map_1.png',
      '46214' => icon_path + 'Indy_map_1.png',
      '46216' => icon_path + 'Indy_map_2.png',
      '46217' => icon_path + 'Indy_map_3.png',
      '46218' => icon_path + 'Indy_map_2.png',
      '46219' => icon_path + 'Indy_map_2.png',
      '46220' => icon_path + 'Indy_map_2.png',
      '46221' => icon_path + 'Indy_map_3.png',
      '46222' => icon_path + 'Indy_map_1.png',
      '46224' => icon_path + 'Indy_map_1.png',
      '46225' => icon_path + 'Indy_map_3.png',
      '46226' => icon_path + 'Indy_map_2.png',
      '46227' => icon_path + 'Indy_map_4.png',
      '46228' => icon_path + 'Indy_map_1.png',
      '46229' => icon_path + 'Indy_map_2.png',
      '46231' => icon_path + 'Indy_map_3.png',
      '46234' => icon_path + 'Indy_map_1.png',
      '46235' => icon_path + 'Indy_map_2.png',
      '46236' => icon_path + 'Indy_map_2.png',
      '46237' => icon_path + 'Indy_map_4.png',
      '46239' => icon_path + 'Indy_map_4.png',
      '46240' => icon_path + 'Indy_map_2.png',
      '46241' => icon_path + 'Indy_map_3.png',
      '46250' => icon_path + 'Indy_map_2.png',
      '46254' => icon_path + 'Indy_map_1.png',
      '46256' => icon_path + 'Indy_map_2.png',
      '46259' => icon_path + 'Indy_map_4.png',
      '46260' => icon_path + 'Indy_map_1.png',
      '46268' => icon_path + 'Indy_map_1.png',
      '46278' => icon_path + 'Indy_map_1.png',
      '53110' => icon_path + 'Mke_map_6.png',
      '53129' => icon_path + 'Mke_map_5.png',
      '53130' => icon_path + 'Mke_map_5.png',
      '53202' => icon_path + 'Mke_map_4.png',
      '53203' => icon_path + 'Mke_map_4.png',
      '53204' => icon_path + 'Mke_map_6.png',
      '53205' => icon_path + 'Mke_map_4.png',
      '53206' => icon_path + 'Mke_map_4.png',
      '53207' => icon_path + 'Mke_map_6.png',
      '53208' => icon_path + 'Mke_map_3.png',
      '53209' => icon_path + 'Mke_map_2.png',
      '53210' => icon_path + 'Mke_map_3.png',
      '53211' => icon_path + 'Mke_map_4.png',
      '53212' => icon_path + 'Mke_map_4.png',
      '53213' => icon_path + 'Mke_map_3.png',
      '53214' => icon_path + 'Mke_map_5.png',
      '53215' => icon_path + 'Mke_map_6.png',
      '53216' => icon_path + 'Mke_map_3.png',
      '53217' => icon_path + 'Mke_map_2.png',
      '53218' => icon_path + 'Mke_map_1.png',
      '53219' => icon_path + 'Mke_map_5.png',
      '53220' => icon_path + 'Mke_map_5.png',
      '53221' => icon_path + 'Mke_map_6.png',
      '53222' => icon_path + 'Mke_map_3.png',
      '53223' => icon_path + 'Mke_map_1.png',
      '53224' => icon_path + 'Mke_map_1.png',
      '53225' => icon_path + 'Mke_map_1.png',
      '53226' => icon_path + 'Mke_map_3.png',
      '53227' => icon_path + 'Mke_map_5.png',
      '53228' => icon_path + 'Mke_map_5.png',
      '53233' => icon_path + 'Mke_map_4.png',
      '53235' => icon_path + 'Mke_map_6.png',
  }

  English_to_spanish_school_type_mapping = {
      'Private' => 'Privada',
      'Public district' => 'Pública',
      'Public charter' => 'Charter Pública'

  }

  English_to_spanish_diversity_mapping = {
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
      'Native Hawaiian' => 'Nativo Hawaiiano',
      'Native Hawaiian or Pacific Islander' => 'Nativo Hawaiiano',
      'Native Hawaiian or Other Pacific Islander' => 'Nativo Hawaiiano',
      'White' => 'Caucásico/Blanco',
      'White, not Hispanic' => 'Caucásico/Blanco'

  }

  English_to_spanish_ell_sped_mapping = {
      'None' => 'Ninguno',
      'Basic' => 'Básicos',
      'Moderate' => 'Moderado',
      'Intensive' => 'Intensivo'
  }


  English_to_spanish_deadline_mapping = {
      'Contact school' => 'Contacta la escuela',
      'Rolling deadline' => 'Abierta todo el año'
  }

  English_to_spanish_ratings_mapping = {
      'Excellent Schools Detroit Rating' => 'Calificación ESD',
      'State Rating' => 'Calificación Estado',
      'Great Start to Quality preschool rating' => 'Calificación prescolar',
      'QRIS Preschool rating' => 'Calificación prescolar'
  }

  def which_school_type
    English_to_spanish_school_type_mapping[decorated_school_type]
  end

  def which_ethnicity_key_mapping(data)
    ethnicity_data = data.map do |k, v|
      [English_to_spanish_diversity_mapping[k], v]
    end
  end

  def which_ell_mapping
    English_to_spanish_ell_sped_mapping[school_cache.ell]
  end

  def which_sped_mapping
    English_to_spanish_ell_sped_mapping[school_cache.sped]
  end

  def which_deadline_mapping
    English_to_spanish_deadline_mapping[school_cache.deadline]
  end

  def which_rating_mapping(data)
    English_to_spanish_ratings_mapping[data]
  end

  def find_schools_to_be_printed(state,collection_id,is_high_school,is_k8,is_pk8,added_schools,removed_schools,school_id1,school_id2,school_id3,school_id4)
    db_schools = []

    # binding.pry;
    if state.present? && collection_id.present? && collection_id>0 && is_high_school
      school_ids = SchoolMetadata.school_ids_for_collection_ids(state, collection_id)
      db_schools = School.on_db(state).active.where(id: school_ids).order(name: :asc).to_a
      db_schools.select!(&:includes_highschool?)

    elsif state.present? && collection_id.present? && collection_id>0  && is_pk8
      school_ids = SchoolMetadata.school_ids_for_collection_ids(state, collection_id)
      db_schools = School.on_db(state).active.where(id: school_ids).order(name: :asc).to_a
      db_schools.select!(&:pk8?)
    elsif state.present? && collection_id.present? && collection_id>0  && is_k8
      school_ids = SchoolMetadata.school_ids_for_collection_ids(state, collection_id)
      db_schools = School.on_db(state).active.where(id: school_ids).order(name: :asc).to_a
      db_schools.select!(&:k8?)
    elsif state.present? && collection_id.present? &&  collection_id>0  && !is_k8  &&  !is_high_school  &&  !is_pk8
      school_ids = SchoolMetadata.school_ids_for_collection_ids(state, collection_id)
      db_schools = School.on_db(state).active.where(id: school_ids).order(name: :asc).to_a

    elsif   state.present? &&  collection_id==0 && (!school_id1.present? || !school_id2.present? || !school_id3.present? || !school_id4.present?)
      db_schools = School.on_db(state).active.order(name: :asc).to_a
    elsif   state.present? && (school_id1.present? || school_id2.present? || school_id3.present? || school_id4.present?)
      db_schools = School.for_states_and_ids([state, state, state,state], [school_id1, school_id2, school_id3, school_id4])
    end

    # Add schools
    if added_schools.present?
      schools_to_be_added = added_schools.split(',')
      db_schools += School.on_db(state).where(id: schools_to_be_added).all
      db_schools.sort! { |a,b| a.name <=> b.name }
    end

    # Remove schools
    if removed_schools.present?
      schools_to_be_removed = removed_schools.split(',')
      db_schools -= School.on_db(state).where(id: schools_to_be_removed).all
      db_schools.sort! { |a,b| a.name <=> b.name }
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
    Zipcode_to_icon_mapping[zipcode].present? ?  Zipcode_to_icon_mapping[zipcode] :'N/A'
  end

end