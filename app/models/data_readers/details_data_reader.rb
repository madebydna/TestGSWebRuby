class DetailsDataReader < SchoolProfileDataReader

  def data_for_category(category)
    #Bugathon - PreK details icons are not ready yet, hence hide the details section temporarily.
    if school.preschool?
      return {}
    end

    data_details = school.esp_data_points category

    details_response_keys = {
      art: ['arts_media', 'arts_music', 'arts_performing_written', 'arts_visual'],
      sport: ['girls_sports', 'boys_sports'],
      club: ['student_clubs'],
      lang: ['foreign_language']
    }

    #need icon sprite size and name.  subtitle w color.  content
    return_counts_details = {

      art:   {count: 'no info', content: 'Arts & music'},
      sport: {count: 'no info', content: 'Sports'},
      club:  {count: 'no info', content: 'Clubs'},
      lang:  {count: 'no info', content: 'World languages'},
      sched: {count: 'Half day', content: 'Preschool schedule'},
      commu: {count: 'Community center', content: 'Care setting'}
    }

    # loop through details and handle total count for 0, infinity cases
    #  zero is a dash -
    #  check if value for all is none
    #  don't add none to count
    details_response_keys.keys.each do |osp_key|
      return_counts_details[osp_key][:count] = details_response_keys[osp_key].sum do | key |
        (Array(data_details[key]).count{|item| item.downcase != "none"})
      end
      if return_counts_details[osp_key][:count] == 0
        none_count = details_response_keys[osp_key].sum do | key |
          (Array(data_details[key]).count{|item| item.downcase == "none"})
        end
        return_counts_details[osp_key][:count] = none_count == 0 ?  "no info" : 0
      end
    end
    return_counts_details
  end

end