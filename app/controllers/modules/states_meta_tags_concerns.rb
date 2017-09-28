module StatesMetaTagsConcerns

  def state_long_name_with_caps
    state_name = @state[:long].gs_capitalize_words
    if @state[:short] == 'dc'
      state_name = "Washington DC";
    end
    state_name
  end

  def states_show_title
    # Testing different title tag for Pennsylvania state page
    current_yr = Date.today.year
    return "#{state_long_name_with_caps} #{current_yr} School Ratings | Public & Private" if %w(pa nj co in).include?(@state[:short].downcase)
    "#{state_long_name_with_caps} Schools - #{state_long_name_with_caps} State School Ratings - Public and Private"
  end

  def states_show_description
    "#{state_long_name_with_caps} school information: Test scores, school parent reviews and more. Plus, get expert advice to help find the right school for your child."
  end

  def states_community_title
    "#{@state[:long].titleize} Education Community"
  end

  def states_community_description
    "Key local and state organizations that make up the #{@state[:long].titleize} education system"
  end
end
