module StatesMetaTagsConcerns

  def state_long_name_with_caps
    state_name = @state[:long].gs_capitalize_words
    if @state[:short] == 'dc'
      state_name = "Washington DC";
    end
    state_name
  end

  def state_school_count 
    School.on_db(@state[:short]).all.active.count
  end 

  def states_show_title
    "2019 #{state_long_name_with_caps} Schools: Public & Private School Ratings & Reviews"
  end

  def states_show_description
    "GreatSchools has ratings & reviews for #{state_school_count} #{state_long_name_with_caps} elementary, middle, & high schools. Find the best public, charter, or private school for your child."
  end

  def states_community_title
    "#{@state[:long].titleize} Education Community"
  end

  def states_community_description
    "Key local and state organizations that make up the #{@state[:long].titleize} education system"
  end
end
