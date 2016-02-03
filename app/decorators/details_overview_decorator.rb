class DetailsOverviewDecorator
  def initialize(data, school, view)
    @data = data
    @school = school
    @view = view
  end

  ["basic_information", "programs_and_culture", "diversity"].each do |action|
    define_method("has_#{action}_data?") do
      send(action).send(:get_data).present?
    end

    define_method("#{action}") do
      klass = DetailsOverviewDecorator.const_get(action.camelcase)
      item = klass.new(
          @data,
          details: @view.school_quality_path(@school),
          quality: @view.school_details_path(@school))
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
      join_values
      sort_based_on_configured_keys
      nil
    end

    def combine_and_rename_keys
      configured_data.each do |k, v|
        configured_key = configured_keys[k]
        @transformed_data[configured_key] << v
      end
    end

    # format values as comma-separated strings
    def join_values
      @transformed_data = Hash[transformed_data.map { |k, v| [k, v.join(', ')] } ]
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
      @links = {'More' => urls[:details]}
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
      @links = {'More program info' => urls[:details]}
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
      @links = {'More diversity info' => urls[:quality]}
    end

    def student_diversity
      diversity_data = data['Student ethnicity']
      Hash[diversity_data.sort_by(&:last).reverse]
    end
  end

end
