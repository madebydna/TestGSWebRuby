module StatesMetaTagsConcerns

  def state_long_name_with_caps
    state_name = @state[:long].gs_capitalize_words
    if @state[:short] == 'dc'
      state_name = "Washington DC";
    end
    state_name
  end

  def states_show_title
    "2019 #{state_long_name_with_caps} Schools | #{state_long_name_with_caps} Schools | Public & Private Schools"
  end

  def states_show_description
    "2019 #{state_long_name_with_caps} school rankings, all #{@state[:short].upcase} public and private schools in #{state_long_name_with_caps} ranked. Click here for #{state_long_name_with_caps} school information plus read ratings and reviews for #{state_long_name_with_caps} schools."
  end

  def states_community_title
    "#{@state[:long].titleize} Education Community"
  end

  def states_community_description
    "Key local and state organizations that make up the #{@state[:long].titleize} education system"
  end
end
