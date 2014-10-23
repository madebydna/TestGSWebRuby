#encoding: utf-8

module SpanishPdfConcerns

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
      'Great Start to Quality preschool rating' => 'Calificación prescolar'
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
end