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
          quality: @view.school_quality_path(@school),
          details: @view.school_details_path(@school))
      item.get_data
    end
  end

  class DetailsInformation
    attr_reader :data, :header, :array_of_keys, :links

    def initialize(data)
      @data = data
    end

    def get_data
      transformed_data = {}

      transformed_data["header"] = header

      raw_data = data.select do |key, value|
        array_of_keys.include? key
      end

      transformed_data["data"] = raw_data

      transformed_data["link"] = links

      if transformed_data["data"].empty?
        return {}
      end

      return transformed_data
    end
  end

  class BasicInformation < DetailsInformation
    def initialize(data, urls)
      super(data)
      @header = "BASIC INFORMATION"
      @array_of_keys = ["Before/After Care", "Dress Code", "Transportation"]
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
      @array_of_keys = ['Student Demographics', 'Free & reduced lunch participants', 'Students w/ disabilities', 'English language learners']
      @links = {"More" => urls[:quality],
                "More diversity info" => urls[:details]}
    end
  end

end