class DetailsOverviewDecorator
  def initialize(data, school, view)
    @data = data
    @school = school
    @view = view
  end

  ["basic_information", "programs_and_culture", "diversity"].each do |action|
    define_method("has_#{action}_data?") do
      send(action).present?
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
    attr_reader :data, :header, :array_of_keys, :links

    def initialize(data)
      @data = data
    end

    def get_data
      @_transformed_data ||= (transformed_data = {}

      transformed_data["header"] = header

      raw_data = data.select {|key, _| array_of_keys.include? key }

      return {} if raw_data.empty?

      data = Hash[
        raw_data.collect do |k,v|
          v = v.values if v.is_a?(Hash) && k != 'Student ethnicity'
          v = v.join(', ') if v.respond_to?(:join)
          [k, v]
        end
      ]

      transformed_data["data"] = data

      transformed_data["link"] = links

      transformed_data)
    end
  end

  class BasicInformation < DetailsInformation
    def initialize(data, urls)
      super(data)
      @header = "BASIC INFORMATION"
      @array_of_keys = ["Before/After Care", "Dress code", "Transportation"]
      @links = {"More" => urls[:details]}
    end
  end

  class ProgramsAndCulture < DetailsInformation
    def initialize(data, urls)
      super(data)
      @header = "PROGRAMS & CULTURE"
      @array_of_keys = ["Academic Focus", "Arts", "World Languages"]
      @links = {"More program info" => urls[:details]}
    end
  end

  class Diversity < DetailsInformation
    def initialize(data, urls)
      super(data)
      @header = "DIVERSITY"
      @array_of_keys = ['Student ethnicity', 'FRL', 'Students with disabilities', 'English language learners']
      @links = {"More" => urls[:details],
                "More diversity info" => urls[:quality]}
    end
  end

end
