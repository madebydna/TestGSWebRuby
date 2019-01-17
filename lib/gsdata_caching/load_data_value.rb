# frozen_string_literal: true

# combines the load and data value model results
class GsdataCaching::LoadDataValue
  def initialize(loads, data_values)
    @loads = loads
    @data_values = data_values
  end

  def merge
    @load_array_hashes = @loads.map do |load|
      build_load_hash(load)
    end

    @data_values.map do |data_value|
      to_hash(data_value)
    end
  end

  def build_load_hash(load)
    # require 'pry'; binding.pry;
    OpenStruct.new.tap do |obj|
      # require 'pry';binding.pry
      obj.load_id = load.id
      obj.source_name = load.source_name
      obj.data_type_id = load.data_type_id
      obj.configuration = load.configuration
      # rubocop:disable Style/FormatStringToken
      obj.date_valid = load.date_valid.strftime('%Y%m%d %T')
      # rubocop:enable Style/FormatStringToken
      obj.description = load.description
      obj.name = load.data_type_name
      obj.short_name = load.data_type_short_name if load.respond_to? :data_type_short_name
    end
  end


  def load_hash(load_id)
    @load_array_hashes.find { |load| load.load_id == load_id}
  end

  def to_hash(data_value)
    # require 'pry'; binding.pry;
    load = load_hash(data_value.load_id)
    # require 'pry'; binding.pry;
    OpenStruct.new.tap do |obj|
      obj.value = data_value.value
      obj.state = data_value.state
      obj.school_id = data_value.school_id if data_value.respond_to? :school_id
      obj.district_id = data_value.district_id if data_value.respond_to? :district_id
      obj.grade = data_value.grade if data_value.respond_to? :grade
      obj.cohort_count = data_value.cohort_count if data_value.respond_to? :cohort_count
      obj.proficiency_band_id = data_value.proficiency_band_id if data_value.respond_to? :proficiency_band_id
      obj.active = data_value.active  if data_value.respond_to? :active
      obj.proficiency_band_name = data_value.proficiency_band_name if data_value.respond_to? :proficiency_band_name
      obj.composite_of_pro_null = data_value.composite_of_pro_null if data_value.respond_to? :composite_of_pro_null
      obj.breakdown_names = data_value.breakdown_names if data_value.respond_to? :breakdown_names
      obj.breakdown_id_list = data_value.breakdown_id_list if data_value.respond_to? :breakdown_id_list
      obj.breakdown_tags = data_value.breakdown_tags if data_value.respond_to? :breakdown_tags
      obj.breakdown_count = data_value.breakdown_count if data_value.respond_to? :breakdown_count
      obj.academic_names = data_value.academic_names if data_value.respond_to? :academic_names
      obj.academic_tags = data_value.academic_tags if data_value.respond_to? :academic_tags
      obj.academic_count = data_value.academic_count if data_value.respond_to? :academic_count
      obj.academic_types = data_value.academic_types if data_value.respond_to? :academic_types
      obj.data_type_id = load.data_type_id
      obj.configuration = load.configuration
      obj.source = load.source_name
      obj.date_valid = load.date_valid
      obj.description = load.description
      obj.name = load.name
      obj.short_name = load.data_type_short_name if load.respond_to? :data_type_short_name
    end
  end
end