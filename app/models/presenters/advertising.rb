class Hash
  def seek(*_keys_)
    last_level    = self
    sought_value  = nil

    _keys_.each_with_index do |_key_, _idx_|
      if last_level.is_a?(Hash) && last_level.has_key?(_key_)
        if _idx_ + 1 == _keys_.length
          sought_value = last_level[_key_]
        else
          last_level = last_level[_key_]
        end
      else
        break
      end
    end

    sought_value
  end
end

class Advertising

  def initialize
    @ad_slots = Hash.new
    # Overview Page Ads
    @ad_slots[:Overview] = {
      Snapshot: {
        name: "Snapshot",
        desktop:{
          width:300,
          height:250
        }
      },
      Reviews: {
        name: "Reviews",
        desktop:{
          width:300,
          height:250
        }
      },
      Media_Gallery: {
        name: "Media_Gallery",
        desktop:{
          width:300,
          height:250
        }
      },
      Details: {
        name: "Details",
        desktop:{
          width:728,
          height:90
        },
        mobile:{
          width:320,
          height:50
        }
      },
      Facebook: {
        name: "Facebook",
        desktop:{
          width:300,
          height:250
        }
      },
      Contact_Info: {
        name: "Contact_Info",
        desktop:{
          width:728,
          height:90
        },
        mobile:{
          width:300,
          height:250
        }
      }
    }

    # Reviews Page Ads
    @ad_slots[:Reviews] = {
      Content_Top: {
        name: "Content_Top",
        desktop:{
          width:300,
          height:250
        }
      },
      Review1: {
        name: "Review1",
        desktop:{
          width:728,
          height:90
        },
        mobile:{
          width:320,
          height:50
        }
      },
      Review2: {
        name: "Review2",
        desktop:{
          width:300,
          height:250
        }
      },
      Review3: {
        name: "Review3",
        desktop:{
          width:728,
          height:90
        },
        mobile:{
          width:320,
          height:50
        }
      },
      Contact_Info: {
        name: "Contact_Info",
        desktop:{
          width:728,
          height:90
        },
        mobile:{
          width:300,
          height:250
        }
      }
    }

    # Quality Page Ads
    @ad_slots[:Quality] = {
      Content_Top: {
        name: "Content_Top",
        desktop:{
          width:300,
          height:250
        }
      },
      Ratings: {
        name: "Ratings",
        desktop:{
          width:728,
          height:90
        },
        mobile:{
          width:320,
          height:50
        }
      },
      Test_Scores1: {
        name: "Test_Scores1",
        desktop:{
          width:300,
          height:250
        }
      },
      Test_Scores2: {
        name: "Test_Scores2",
        desktop:{
          width:300,
          height:250
        }
      },
      Test_Scores3: {
        name: "Test_Scores3",
        desktop:{
          width:300,
          height:250
        }
      },Test_Scores4: {
        name: "Test_Scores4",
        desktop:{
          width:300,
          height:250
        }
      },
      Test_Scores5: {
        name: "Test_Scores5",
        desktop:{
          width:300,
          height:250
        }
      },
      College_Readiness: {
        name: "College_Readiness",
        desktop:{
          width:728,
          height:90
        },
        mobile:{
          width:300,
          height:250
        }
      },
      Climate: {
        name: "Climate",
        desktop:{
          width:300,
          height:250
        }
      },
      Contact_Info: {
        name: "Contact_Info",
        desktop:{
          width:728,
          height:90
        },
        mobile:{
          width:300,
          height:250
        }
      }
    }

    # Details Page Ads
    @ad_slots[:Details] = {
      Content_Top: {
        name: "Content_Top",
        desktop:{
          width:300,
          height:250
        }
      },
      Students: {
        name: "Students",
        desktop:{
          width:728,
          height:90
        },
        mobile:{
          width:320,
          height:50
        }
      },
      Programs: {
        name: "Programs",
        desktop:{
          width:300,
          height:250
        }
      },
      Culture: {
        name: "Culture",
        desktop:{
          width:728,
          height:90
        },
        mobile:{
          width:320,
          height:50
        }
      },
      Teachers: {
        name: "Teachers",
        desktop:{
          width:300,
          height:250
        }
      },
      Neighborhood: {
        name: :Neighborhood,
        desktop:{
          width:728,
          height:90
        },
        mobile:{
          width:320,
          height:50
        }
      },
      Enrollment: {
        name: "Enrollment",
        desktop:{
          width:300,
          height:250
        }
      },
      Sources: {
        name: "Sources",
        desktop:{
          width:300,
          height:250
        }
      },
      Contact_Info: {
        name: "Contact_Info",
        desktop:{
          width:728,
          height:90
        },
        mobile:{
          width:300,
          height:250
        }
      }
    }

    def get_width(page, slot, view)
      hash_val = @ad_slots.seek page, slot, :desktop
      if hash_val.present?
        @ad_slots[page][slot][view].nil? ? @ad_slots[page][slot][:desktop][:width] : @ad_slots[page][slot][view][:width]
      end
    end

    def get_height(page, slot, view)
      hash_val = @ad_slots.seek page, slot, :desktop
      if hash_val.present?
        @ad_slots[page][slot][view].nil? ? @ad_slots[page][slot][:desktop][:height] : @ad_slots[page][slot][view][:height]
      end
    end

  end
end