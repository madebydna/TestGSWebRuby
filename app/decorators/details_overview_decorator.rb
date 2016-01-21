class DetailsOverviewDecorator
  def initialize(data, school, view)
    @data = data
    @school = school
    @view = view
  end

  def basic_information
    transformed_data = {}

    transformed_data["header"] = "BASIC INFORMATION"

    basic_information_data = @data.select do |key, value|
      array_of_keys = ["Before/After Care", "Dress Code", "Transportation"]
      array_of_keys.include? key
    end

    transformed_data["data"] = basic_information_data

    more_data = {
      "More" => @view.school_details_path(@school)
    }

    transformed_data["link"] = more_data

    return transformed_data
  end

  def programs_and_culture
    transformed_data = {}

    transformed_data["header"] = "PROGRAMS & CULTURE"

    programs_and_culture_data = @data.select do |key, value|
      array_of_keys = ["Academic Focus", "Arts", "World Languages"]
      array_of_keys.include? key
    end

    transformed_data["data"] = programs_and_culture_data

    more_data = {
        "More program info" => @view.school_details_path(@school)
    }

    transformed_data["link"] = more_data

    return transformed_data
  end

  def diversity
    transformed_data = {}

    transformed_data["header"] = "DIVERSITY"

    diversity_data = @data.select do |key, value|
      array_of_keys = ["Student Demographics", "Free & reduced lunch participants", "Students w/ disabilities", "English language learners"]
      array_of_keys.include? key
    end

    transformed_data["data"] = diversity_data

    more_data = {
      "More" => @view.school_details_path(@school),
      "More diversity info" => @view.school_details_path(@school)
    }

    transformed_data["link"] = more_data

    return transformed_data
  end

end