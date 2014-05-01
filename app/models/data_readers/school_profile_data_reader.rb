class SchoolProfileDataReader

  attr_accessor :school

  delegate :page, to: :school

  def initialize(school)
    @school = school
  end

  # Sort the hash the same way the keys are sorted in the config
  #
  def sort_based_on_config(key_to_results_hash, category)
    keys = category.keys(school.collections)
    Hash[
      key_to_results_hash.sort_by do |key , _|
        position = keys.index(key)
        position = 1 if position.nil?
        position
      end
    ]
  end

  # Makes a new hash from an existing hash, by transforming keys by using a
  # key-to-label lookup map
  #
  # reader.labelize_hash_keys({
  #   "Climate: Effective Leaders - Overall" => [
  #      {
  #       :breakdown => nil,
  #       :school_value => 83.0,
  #       :district_value => nil,
  #       :state_value => nil
  #     }
  #   ]
  # })                                #=> "Effective Leaders - Overall" => [
  #                                           {
  #                                             :breakdown => nil,
  #                                             :school_value => 83.0,
  #                                             :district_value => nil,
  #                                             :state_value => nil
  #                                           }
  #                                         ],
  #                                       }
  #
  def labelize_hash_keys(hash, key_label_map)
    new_hash = {}
    hash.each do |key, values|
      label = key_label_map.fetch(key, key)
      label = key if label.blank?
      new_hash[label] = values
    end

    new_hash
  end

end