class DetailsOverviewDecorator
  def initialize(data, school, view)
    @data = data
    @school = school
    @view = view
  end

  def get_data(header, array_of_keys, links = {})
    transformed_data = {}

    transformed_data["header"] = header

    raw_data = @data.select do |key, value|
      array_of_keys.include? key
    end

    transformed_data["data"] = raw_data

    transformed_data["link"] = links

    if transformed_data["data"].empty?
      return {}
    end

    return transformed_data
  end

  ["basic_information", "programs_and_culture", "diversity"].each do |action|
    define_method("has_#{action}_data?") do
      send(action).present?
    end
  end

  def basic_information
    header = "BASIC INFORMATION"
    array_of_keys = ["Before/After Care", "Dress Code", "Transportation"]
    links = {"More" => @view.school_details_path(@school)}

    get_data(header, array_of_keys, links)
  end

  def programs_and_culture
    header = "PROGRAMS & CULTURE"
    array_of_keys = ["Academic Focus", "Arts", "World Languages"]
    links = {"More program info" => @view.school_details_path(@school)}

    get_data(header, array_of_keys, links)
  end

  def diversity
    header = "DIVERSITY"
    array_of_keys = ['Student Demographics', 'Free & reduced lunch participants', 'Students w/ disabilities', 'English language learners']
    links = {"More" => @view.school_details_path(@school),
             "More diversity info" => @view.school_details_path(@school)}

    get_data(header, array_of_keys, links)
  end

end