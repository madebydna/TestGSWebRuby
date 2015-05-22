#test helper to return school cache hashes without created school cache objects
module SchoolCacheHelper
  def school_cache_data
    characteristics.merge(reviews_snapshot.merge(esp_responses.merge(ratings)))
  end

  #for saving into a test db
  def create_school_cache_set_in_db!(school_id, state)
    char = {name: 'characteristics', value: characteristics['characteristics']}
    rev = { name: 'reviews_snapshot', value: reviews_snapshot['reviews_snapshot']}
    esp = { name: 'esp_responses', value: esp_responses['esp_responses']}
    rat = { name: 'ratings', value: ratings['ratings']}
    nbs = { name: 'nearby_schools', value: nearby_schools['nearby_schools']}

    yield char[:value], rev[:value], esp[:value], rat[:value], nbs[:value] if block_given?

    save_school_cache_to_db!(school_id, state, [char, rev, esp, rat, nbs])
  end

  def save_school_cache_to_db!(school_id, state, cache_data)
    [*cache_data].each do | c_data |
      FactoryGirl.create(:school_cache, name: c_data[:name], school_id: school_id, state: state, value: c_data[:value].to_json)
    end
  end

  #generic layout for different data types. modify with blocks where desired
  def characteristics
    char = {
      "characteristics" => {
        "Ethnicity" => [
          {"year"=>2014, "source"=>"DE Dept. of Education", "breakdown"=>"White", "school_value"=>59.0, "state_average"=>47.7},
          {"year"=>2014, "source"=>"DE Dept. of Education", "breakdown"=>"Black", "school_value"=>29.7, "state_average"=>31.3},
          {"year"=>2014, "source"=>"DE Dept. of Education", "breakdown"=>"Hispanic", "school_value"=>6.2, "state_average"=>14.5},
          {"year"=>2014, "source"=>"DE Dept. of Education", "breakdown"=>"Asian", "school_value"=>3.5, "state_average"=>3.5},
          {"year"=>2014, "source"=>"DE Dept. of Education", "breakdown"=>"Two or more races", "state_average"=>2.5},
          {"year"=>2014, "source"=>"DE Dept. of Education", "breakdown"=>"Native American", "state_average"=>0.4},
          {"year"=>2014, "source"=>"DE Dept. of Education", "breakdown"=>"Hawaiian", "school_value"=>0.0, "state_average"=>0.1},
          {"year"=>2014, "source"=>"DE Dept. of Education", "breakdown"=>"American Indian/Alaska Native", "school_value"=>0.0, "state_average"=>0.0}
        ],
        "Enrollment" => [
          {"year"=>2014, "source"=>"DE Dept. of Education", "school_value"=>1281.0}
        ],
      }
    }
    yield char if block_given?
    char
  end

  def reviews_snapshot
    reviews = {
      "reviews_snapshot" => {
        "num_ratings" => 8,
        "num_reviews" => 3
      }
    }
    yield reviews if block_given?
    reviews
  end

  def esp_responses
    esp = {
      "esp_responses" => {
        "foreign_language" => {
          "mandarin"=> {
            "member_id"=>5351255,
            "source"=>"usp",
            "created"=>"2013-12-04T12:46:47.000-08:00"
          },
          "japanese"=> {
            "member_id"=>5351255,
            "source"=>"usp",
            "created"=>"2013-12-04T12:46:47.000-08:00"
          },
          "spanish"=> {
            "member_id"=>5351255,
            "source"=>"usp",
            "created"=>"2013-12-04T12:46:47.000-08:00"
          }
        },
        "transportation" => {
          "busses" => {
            "member_id"=>5351255,
            "source"=>"usp",
            "created"=>"2013-12-04T12:46:47.000-08:00"
          },
          "accessible_via_public_transportation"=> {
            "member_id"=>5351255,
            "source"=>"usp",
            "created"=>"2013-12-04T12:46:47.000-08:00"
          }
        },
        "before_after_care" => {
          "before" => {
            "member_id"=>5351255,
            "source"=>"usp",
            "created"=>"2013-12-04T12:46:47.000-08:00"
          }
        }
      }
    }
    yield esp if block_given?
    esp
  end

  def ratings
    rat = {
      "ratings" => [
        {
          "data_type_id"=>166,
          "year"=>2014,
          "school_value_text"=>nil,
          "school_value_float"=>8.0
        },
        {
          "data_type_id"=>164,
          "year"=>2014,
          "school_value_text"=>nil,
          "school_value_float"=>8.0
        },
        {
          "data_type_id"=>165,
          "year"=>2014,
          "school_value_text"=>nil,
          "school_value_float"=>9.0
        },
        {
          "data_type_id"=>174,
          "year"=>2014,
          "school_value_text"=>nil,
          "school_value_float"=>8.0
        }
      ]
    }
    yield rat if block_given?
    rat
  end

  def nearby_schools
      nbs = {
        "nearby_schools" => [
            {"id"=>8234,"name"=>"Saint Joseph Notre Dame High School","city"=>"Alameda","state"=>"CA","gs_rating"=>"nr","type"=>"private","level"=>"9-12","review_score"=>4,"review_count"=>16},
            {"id"=>17573,"name"=>"Arise High School","city"=>"Oakland","state"=>"CA","gs_rating"=>"2","type"=>"charter","level"=>"9-12","review_score"=>3,"review_count"=>3},
            {"id"=>8208,"name"=>"Saint Elizabeth High School","city"=>"Oakland","state"=>"CA","gs_rating"=>"nr","type"=>"private","level"=>"9-12","review_score"=>3,"review_count"=>8},
            {"id"=>14052,"name"=>"Alameda Science And Technology Institute","city"=>"Alameda","state"=>"CA","gs_rating"=>"9","type"=>"public","level"=>"9-12","review_score"=>4,"review_count"=>19},
            {"id"=>12550,"name"=>"Metwest High School","city"=>"Oakland","state"=>"CA","gs_rating"=>"3","type"=>"public","level"=>"9-12","review_score"=>4,"review_count"=>14}
        ]
      }
      yield nbs if block_given?
      nbs
  end

end