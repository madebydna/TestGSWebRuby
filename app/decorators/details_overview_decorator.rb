class DetailsOverviewDecorator
  def initialize(data, school, view)
    @data = data
    @school = school
    @view = view
  end

  ["basic_information", "programs_and_culture"].each do |action|
    define_method("has_#{action}_data?") do
      send(action).send(:get_data).present?
    end
  end

  def has_diversity_data?
    @data['Student ethnicity'].present?
  end

  ["basic_information", "programs_and_culture", "diversity"].each do |action|

    define_method("#{action}") do
      klass = DetailsOverviewDecorator.const_get(action.camelcase)
      item = klass.new(
          @data,
          details: @view.school_details_path(@school),
          quality: @view.school_quality_path(@school))
      item
    end
  end

  class DetailsInformation
    attr_reader :data, :header, :configured_keys, :links, :transformed_data

    def initialize(data)
      @data = data
      @transformed_data = Hash.new { |hash, key| hash[key] = [] }
    end

    def get_data
      @_get_data ||= begin
        transform_data
        # Only return first three pairs
        Hash[transformed_data.take(3)]
      end
    end

    private

    def sort_based_on_configured_keys
      @transformed_data = Hash[
        @transformed_data.sort_by { |key, _| configured_keys.values.index(key) }
      ]
    end

    def transform_data
      combine_and_rename_keys
      format_values
      sort_based_on_configured_keys
      translate_keys
      nil
    end

    def translate_keys
      @transformed_data = @transformed_data.each_with_object({}) do |(k,v), hash|
        hash[I18n.t(k.to_sym, scope:'decorators.details_overview_decorator')] = v
      end
    end

    def combine_and_rename_keys
      configured_data.each do |k, v|
        configured_key = configured_keys[k]
        if v.is_a?(Hash)
          @transformed_data[configured_key] << v
        else
          @transformed_data[configured_key] = @transformed_data[configured_key] + v
        end
      end
    end

    # format values as unique comma-separated strings and capitalize the first word
    def format_values
      formatted_data = transformed_data.map do |k, v|
        capitalized_values =  v.map(&:gs_capitalize_first)
        unique_values = capitalized_values.uniq
        value = unique_values.join(', ')
        [k,value]
      end
      @transformed_data = Hash[formatted_data]
    end

    def configured_data
      @_configured_data ||= data.select { |key, _| configured_keys.has_key?(key) }
    end
  end

  class BasicInformation < DetailsInformation
    def initialize(data, urls)
      super(data)
      @header = 'BASIC INFORMATION'
      @configured_keys = {
        'Before / After care'   => 'Before / After care',
        'Dress policy'          => 'Dress policy',
        'Transportation'        => 'Transportation',
        'Coed / Single gender'  => 'Coed / Single gender',
        'Facilities'            => 'Facilities'
      }
      @links = {I18n.t(:more, scope:'decorators.details_overview_decorator') => urls[:details]}
    end
  end

  class ProgramsAndCulture < DetailsInformation
    def initialize(data, urls)
      super(data)
      @header = 'PROGRAMS & CULTURE'
      @configured_keys = {
        'Academic focus'          => 'Academic focus',
        'Arts media'              => 'Arts',
        'Arts music'              => 'Arts',
        'Arts performing written' => 'Arts',
        'Arts visual'             => 'Arts',
        'World languages'         => 'World languages',
        'Boys sports'             => 'Sports',
        'Girls sports'            => 'Sports',
        'Student clubs'           => 'Student clubs'
      }
      @links = {I18n.t(:more_program_info, scope:'decorators.details_overview_decorator') => urls[:details]}
    end
  end

  class Diversity < DetailsInformation
    def initialize(data, urls)
      super(data)
      @header = 'DIVERSITY'
      @configured_keys = {
        'Free or reduced lunch'       => 'Free or reduced lunch',
        'Students with disabilities'  => 'Students with disabilities',
        'English language learners'   => 'English language learners'
      }
      @links = {I18n.t(:more_diversity_info, scope:'decorators.details_overview_decorator') => urls[:quality]}
    end

    def format_values
      @transformed_data = Hash[transformed_data.map { |k, v| [k, v.first.values.first] } ]
    end

    def student_diversity
      diversity_data = data['Student ethnicity']
      Hash[diversity_data.sort_by(&:last).reverse]
    end
  end

end