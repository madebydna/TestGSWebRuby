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

  def which_school_type
    English_to_spanish_school_type_mapping[decorated_school_type]
  end

  def which_ethnicity_key_mapping(data)
    ethnicity_data = data.map do |k, v|
      [English_to_spanish_diversity_mapping[k], v]
    end
  end
end