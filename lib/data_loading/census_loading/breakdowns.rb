module CensusLoading::Breakdowns

  def convert_breakdown_to_id(breakdown)
    if breakdown
      eth = CensusLoading::Base.census_data_ethnicities[breakdown]
      if eth
        breakdown_as_array = CensusLoading::Base.census_data_breakdowns.find do |id, breakdown|
          breakdown[:ethnicity_id] == eth.id
        end
        if breakdown_as_array
          breakdown_as_array[1].id
        else
          raise "Ethnicity '#{breakdown}' is not listed in the census breakdown table"
        end
      else
        raise "Unknown ethnicity: #{breakdown}"
      end
    end
  end

end
