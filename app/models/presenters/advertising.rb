class Advertising

  def initialize
    @ad_slots = Hash.new
    # Overview Page Ads
    @ad_slots[:School_Overview] = {
      Snapshot: {
        name: "Snapshot",
        desktop:{
          width:300,
          height:250,
          dimensions:[300,250]
        }
      },
      Reviews: {
        name: "Reviews",
        desktop:{
          width:300,
          height:250,
          dimensions:[[300,600],[300,250]]
        }
      },
      Media_Gallery: {
        name: "Media_Gallery",
        desktop:{
          width:300,
          height:250,
          dimensions:[300,250]
        }
      },
      Details: {
        name: "Details",
        desktop:{
          width:728,
          height:90,
          dimensions:[728,90]
        },
        mobile:{
          width:320,
          height:50,
          dimensions:[320,50]
        }
      },
      Facebook: {
        name: "Facebook",
        desktop:{
          width:300,
          height:250,
          dimensions:[300,250]
        }
      },
      Contact_Info: {
        name: "Contact_Info",
        desktop:{
          width:728,
          height:90,
          dimensions:[728,90]
        },
        mobile:{
          width:300,
          height:250,
          dimensions:[300,250]
        }
      }
    }

    # Reviews Page Ads
    @ad_slots[:School_Reviews] = {
      Content_Top: {
        name: "Content_Top",
        desktop:{
          width:300,
          height:250,
          dimensions:[300,250]
        }
      },
      Review1: {
        name: "Review1",
        desktop:{
          width:728,
          height:90,
          dimensions:[728,90]
        },
        mobile:{
          width:320,
          height:50,
          dimensions:[320,50]
        }
      },
      Review2: {
        name: "Review2",
        desktop:{
          width:300,
          height:250,
          dimensions:[300,250]
        }
      },
      Review3: {
        name: "Review3",
        desktop:{
          width:728,
          height:90,
          dimensions:[728,90]
        },
        mobile:{
          width:320,
          height:50,
          dimensions:[320,50]
        }
      },
      Contact_Info: {
        name: "Contact_Info",
        desktop:{
          width:728,
          height:90,
          dimensions:[728,90]
        },
        mobile:{
          width:300,
          height:250,
          dimensions:[300,250]
        }
      }
    }

    # Quality Page Ads
    @ad_slots[:School_Quality] = {
      Content_Top: {
        name: "Content_Top",
        desktop:{
          width:300,
          height:250,
          dimensions:[300,250]
        }
      },
      Ratings: {
        name: "Ratings",
        desktop:{
          width:728,
          height:90,
          dimensions:[728,90]
        },
        mobile:{
          width:320,
          height:50,
          dimensions:[320,50]
        }
      },
      Test_Scores1: {
        name: "Test_Scores1",
        desktop:{
          width:300,
          height:250,
          dimensions:[300,250]
        }
      },
      Test_Scores2: {
        name: "Test_Scores2",
        desktop:{
          width:300,
          height:250,
          dimensions:[300,250]
        }
      },
      Test_Scores3: {
        name: "Test_Scores3",
        desktop:{
          width:300,
          height:250,
          dimensions:[300,250]
        }
      },Test_Scores4: {
        name: "Test_Scores4",
        desktop:{
          width:300,
          height:250,
          dimensions:[300,250]
        }
      },
      Test_Scores5: {
        name: "Test_Scores5",
        desktop:{
          width:300,
          height:250,
          dimensions:[300,250]
        }
      },
      College_Readiness: {
        name: "College_Readiness",
        desktop:{
          width:728,
          height:90,
          dimensions:[728,90]
        },
        mobile:{
          width:300,
          height:250,
          dimensions:[300,250]
        }
      },
      Climate: {
        name: "Climate",
        desktop:{
          width:300,
          height:250,
          dimensions:[300,250]
        }
      },
      Contact_Info: {
        name: "Contact_Info",
        desktop:{
          width:728,
          height:90,
          dimensions:[728,90]
        },
        mobile:{
          width:300,
          height:250,
          dimensions:[300,250]
        }
      }
    }

    # Details Page Ads
    @ad_slots[:School_Details] = {
      Content_Top: {
        name: "Content_Top",
        desktop:{
          width:300,
          height:250,
          dimensions:[300,250]
        }
      },
      Students: {
        name: "Students",
        desktop:{
          width:728,
          height:90,
          dimensions:[728,90]
        },
        mobile:{
          width:320,
          height:50,
          dimensions:[320,50]
        }
      },
      Programs: {
        name: "Programs",
        desktop:{
          width:300,
          height:250,
          dimensions:[300,250]
        }
      },
      Culture: {
        name: "Culture",
        desktop:{
          width:728,
          height:90,
          dimensions:[728,90]
        },
        mobile:{
          width:320,
          height:50,
          dimensions:[320,50]
        }
      },
      Teachers: {
        name: "Teachers",
        desktop:{
          width:300,
          height:250,
          dimensions:[300,250]
        }
      },
      Neighborhood: {
        name: :Neighborhood,
        desktop:{
          width:728,
          height:90,
          dimensions:[728,90]
        },
        mobile:{
          width:320,
          height:50,
          dimensions:[320,50]
        }
      },
      Enrollment: {
        name: "Enrollment",
        desktop:{
          width:300,
          height:250,
          dimensions:[300,250]
        }
      },
      Sources: {
        name: "Sources",
        desktop:{
          width:300,
          height:250,
          dimensions:[300,250]
        }
      },
      Contact_Info: {
        name: "Contact_Info",
        desktop:{
          width:728,
          height:90,
          dimensions:[728,90]
        },
        mobile:{
          width:300,
          height:250,
          dimensions:[300,250]
        }
      }
    }
    # City Home Page Ads
    @ad_slots[:City_Home] = {
      Content_Top: {
        name: "Content_Top",
        desktop:{
          width:300,
          height:250,
          dimensions:[300,250]
        }
      },
      Footer: {
        name: "Footer",
        desktop:{
          width:728,
          height:90,
          dimensions:[728,90]
        },
        mobile:{
          width:320,
          height:50,
          dimensions:[320,50]
        }
      },
    }
    # State Home Page Ads
    @ad_slots[:State_Home] = {
      Content_Top: {
        name: "Content_Top",
        desktop:{
          width:300,
          height:250,
          dimensions:[300,250]
        }
      },
      Footer: {
        name: "Footer",
        desktop:{
          width:728,
          height:90,
          dimensions:[728,90]
        },
        mobile:{
          width:320,
          height:50,
          dimensions:[320,50]
        }
      },
    }

    # State Home Page Ads
    @ad_slots[:Homepage] = {
      Pos1: {
        name: "Pos1",
        desktop:{
          width:300,
          height:250,
          dimensions:[300,250]
        }
      },
      Pos2: {
        name: "Pos2",
        desktop:{
          width:728,
          height:90,
          dimensions:[728,90]
        },
        mobile:{
          width:320,
          height:50,
          dimensions:[320,50]
        }
      },
    }

    Homepage_Pos1

    def get_width(page, slot, view)
      ret_value = 0
      dim_array = get_dimensions(page, slot, view)
      if dim_array.is_a? Array
        if dim_array[0].is_a? Array
          ret_value = dim_array[0][0]
        else
          ret_value = dim_array[0]
        end
      end
      ret_value
    end

    def get_height(page, slot, view)
      ret_value = 0
      dim_array = get_dimensions(page, slot, view)
      if dim_array.is_a? Array
        if dim_array[0].is_a? Array
          ret_value = dim_array[0][1]
        else
          ret_value = dim_array[1]
        end
      end
      ret_value
    end


    def get_dimensions(page, slot, view = :desktop)
      desktop_config_val = (@ad_slots.seek(page, slot, view) || @ad_slots.seek(page, slot, :desktop))
      desktop_config_val[:dimensions] if desktop_config_val.present?
    end

  end
end