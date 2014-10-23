#encoding: utf-8

module SpanishPdfConcerns

  English_to_spanish_school_type_mapping = {
      'Private' => 'Privada',
      'Public district' => 'Pública',
      'Public charter' => 'Charter Pública'

  }

  English_to_spanish_diversity_mapping = {
      'White, not Hispanic' => 'Caucásico/Blanco',
      'Hispanic' => 'Hispano/Latino',
      'Native Hawaiian or Other Pacific Islander' => 'Nativo Hawaiiano',
      'Multiracial' => 'De raza multiple/otro',
      'Black, not Hispanic' => 'Afroamericano/Negro',
      'Asian' => 'Asiático',
      'American Indian/Alaskan Native' => 'Amerindio/Nativo Americano'
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