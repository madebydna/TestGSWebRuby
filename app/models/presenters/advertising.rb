class Advertising

  # NOTE: For ad slots with multiple sizes:  order in which dimensions are listed matters. First dimension determines
  # ad slot name.
  def initialize
    @ad_slots = Hash.new

    # Overview Page Ads
    @ad_slots[:School_Overview] = {
      Snapshot: {
        name: "Snapshot",
        desktop:{
            dimensions:[[300,600],[300,250]]
        },
        mobile:{
            dimensions:[300,250]
        }
      },
      Reviews: {
        name: "Reviews",
        desktop:{
          dimensions:[[300,600],[300,250]]
        },
        mobile:{
          dimensions:[300,250]
        }
      },
      Media_Gallery: {
        name: "Media_Gallery",
        desktop:{
          dimensions:[300,250]
        }
      },
      Details: {
        name: "Details",
        desktop:{
          dimensions:[728,90]
        },
        mobile:{
          dimensions:[320,50]
        }
      },
      Facebook: {
        name: "Facebook",
        desktop:{
          dimensions:[300,250]
        }
      },
      Custom: {
        name: "Custom",
        desktop:{
            dimensions:[[970,250],[728,90]]
        }
      },
      Contact_Info: {
        name: "Contact_Info",
        desktop:{
          dimensions:[728,90]
        },
        mobile:{
          dimensions:[300,250]
        }
      },
      Nearby_Schools: {
        name: "Nearby_Schools",
        desktop:{
          dimensions:[300,250]
        }
      },
      Text: {
        name: "Text",
        desktop:{
          dimensions:[[728,60],[728,90]]
        },
        mobile:{
          dimensions:[[320,60],[320,50]]
        }
      }
    }

    # Reviews Page Ads
    @ad_slots[:School_Reviews] = {
      Content_Top: {
        name: "Content_Top",
        desktop:{
          dimensions:[728,90]
        },
        mobile:{
          dimensions:[320,50]
        }
      },
      CTA: {
        name: "CTA",
        desktop:{
          dimensions:[300,250]
        }
      },
      Review1: {
        name: "Review1",
        desktop:{
          dimensions:[728,90]
        },
        mobile:{
          dimensions:[320,50]
        }
      },
      Review2: {
        name: "Review2",
        desktop:{
          dimensions:[300,250]
        }
      },
      Review3: {
        name: "Review3",
        desktop:{
          dimensions:[728,90]
        },
        mobile:{
          dimensions:[320,50]
        }
      },
      Contact_Info: {
        name: "Contact_Info",
        desktop:{
          dimensions:[728,90]
        },
        mobile:{
          dimensions:[300,250]
        }
      },
      Text: {
        name: "Text",
        desktop:{
          dimensions:[[728,60],[728,90]]
        },
        mobile:{
          dimensions:[[320,60],[320,50]]
        }
      },
      Nearby_Schools: {
        name: "Nearby_Schools",
        desktop:{
          dimensions:[300,250]
        }
      }
    }

    # Quality Page Ads
    @ad_slots[:School_Quality] = {
      Content_Top: {
        name: "Content_Top",
        desktop:{
          dimensions:[728,90]
        },
        mobile:{
          dimensions:[320,50]
        }
      },
      CMS: {
        name: "CMS",
        desktop:{
          dimensions:[300,250]
        }
      },
      Ratings: {
        name: "Ratings",
        desktop:{
          dimensions:[728,90]
        },
        mobile:{
          dimensions:[320,50]
        }
      },
      Test_Scores1: {
        name: "Test_Scores1",
        desktop:{
          dimensions:[300,250]
        }
      },
      Test_Scores2: {
        name: "Test_Scores2",
        desktop:{
          dimensions:[300,250]
        }
      },
      Test_Scores3: {
        name: "Test_Scores3",
        desktop:{
          dimensions:[300,250]
        }
      },
      Test_Scores4: {
        name: "Test_Scores4",
        desktop:{
          dimensions:[300,250]
        }
      },
      Test_Scores5: {
        name: "Test_Scores5",
        desktop:{
          dimensions:[300,250]
        }
      },
      College_Readiness: {
        name: "College_Readiness",
        desktop:{
          dimensions:[728,90]
        },
        mobile:{
          dimensions:[300,250]
        }
      },
      Climate: {
        name: "Climate",
        desktop:{
          dimensions:[300,250]
        }
      },
      Contact_Info: {
        name: "Contact_Info",
        desktop:{
          dimensions:[728,90]
        },
        mobile:{
          dimensions:[300,250]
        }
      },
      Nearby_Schools: {
        name: "Nearby_Schools",
        desktop:{
          dimensions:[300,250]
        }
      }
    }

    # Details Page Ads
    @ad_slots[:School_Details] = {
      Content_Top: {
        name: "Content_Top",
        desktop:{
          dimensions:[728,90]
        },
        mobile:{
          dimensions:[320,50]
        }
      },
      CMS: {
        name: "CMS",
        desktop:{
          dimensions:[300,250]
        }
      },
      Students: {
        name: "Students",
        desktop:{
          dimensions:[728,90]
        },
        mobile:{
          dimensions:[320,50]
        }
      },
      Programs: {
        name: "Programs",
        desktop:{
          dimensions:[300,250]
        }
      },
      Culture: {
        name: "Culture",
        desktop:{
          dimensions:[728,90]
        },
        mobile:{
          dimensions:[320,50]
        }
      },
      Teachers: {
        name: "Teachers",
        desktop:{
          dimensions:[300,250]
        }
      },
      Neighborhood: {
        name: :Neighborhood,
        desktop:{
          dimensions:[728,90]
        },
        mobile:{
          dimensions:[320,50]
        }
      },
      Enrollment: {
        name: "Enrollment",
        desktop:{
          dimensions:[300,250]
        }
      },
      Sources: {
        name: "Sources",
        desktop:{
          dimensions:[300,250]
        }
      },
      Contact_Info: {
        name: "Contact_Info",
        desktop:{
          dimensions:[728,90]
        },
        mobile:{
          dimensions:[300,250]
        }
      },
      Nearby_Schools: {
        name: "Nearby_Schools",
        desktop:{
          dimensions:[300,250]
        }
      }
    }

    # City Home Page Ads
    @ad_slots[:City_Home] = {
      Content_Top: {
        name: "Content_Top",
        desktop:{
          dimensions:[300,250]
        }
      },
      Footer: {
        name: "Footer",
        desktop:{
          dimensions:[728,90]
        },
        mobile:{
          dimensions:[320,50]
        }
      },
    }

    # State Home Page Ads
    @ad_slots[:State_Home] = {
      Content_Top: {
        name: "Content_Top",
        desktop:{
          dimensions:[300,250]
        }
      },
      Footer: {
        name: "Footer",
        desktop:{
          dimensions:[728,90]
        },
        mobile:{
          dimensions:[320,50]
        }
      },
    }

    @ad_slots[:District_Home] = {
      Nearby_Schools: {
        name: "Nearby_Schools",
        desktop:{
          dimensions:[300,250]
        }
      },
      Content_Top: {
        name: "Content_Top",
        desktop:{
          dimensions:[300,250]
        }
      },
      Text: {
        name: "Text",
        desktop:{
          dimensions:[[728,60],[728,90]]
        },
        mobile:{
          dimensions:[[320,60],[320,50]]
        }
      },
      Footer: {
        name: "Footer",
        desktop:{
          dimensions:[728,90]
        },
        mobile:{
          dimensions:[320,50]
        }
      },
    }

    # State Home Page Ads
    @ad_slots[:Homepage] = {
      Choosing_Content: {
        name: "Choosing_Content",
        desktop:{
          dimensions:[300,250]
        }
      },
      Parenting_Content: {
        name: "Parenting_Content",
        desktop:{
          dimensions:[300,250]
        }
      },
      Custom: {
        name: "Custom",
        desktop:{
          dimensions:[[970,250],[728,90]]
        }
      }
    }

    @ad_slots[:State_Home_Standard] = {
      Content_Top_Text: {
        name: "Content_Top_Text",
        desktop:{
          dimensions:[[728,60],[728,90]]
        },
        mobile:{
          dimensions:[[320,60],[320,50]]
        }
      },
      Content_Top: {
        name: "Content_Top",
        desktop:{
          dimensions:[300,250]
        }
      },
      Footer: {
        name: "Footer",
        desktop:{
          dimensions:[728,90]
        },
        mobile:{
          dimensions:[320,50]
        }
      },
    }

    # Search Result Ads
    @ad_slots[:Search] = {
      Content_Top: {
        name: "Content_Top",
        desktop:{
          dimensions:[728,90]
        },
        mobile:{
            dimensions:[320,50]
        }
      },
      Footer: {
          name: "Footer",
          desktop:{
            dimensions:[728,90]
          },
          mobile:{
            dimensions:[320,50]
          }
      },
      After4: {
          name: "After4",
          desktop:{
            dimensions:[728,90]
          },
          mobile:{
            dimensions:[300,250]
          }
      },
      After8_Text: {
          name: "After8_Text",
          desktop:{
            dimensions:[[728,60],[728,90]]
          },
          mobile:{
            dimensions:[[320,60],[320,50]]
          }
      },
      After12_Left: {
          name: "After12_Left",
          desktop:{
              dimensions:[300,250]
          }
      },
      After12_Right: {
          name: "After12_Right",
          desktop:{
              dimensions:[300,250]
          }
      },
      After12: {
          name: "After12",
          mobile:{
            dimensions:[320,50]
          }
      },
      After16: {
          name: "After16",
          desktop:{
              dimensions:[728,90]
          },
          mobile:{
              dimensions:[300,250]
          }
      },
      After20: {
          name: "After20",
          desktop:{
              dimensions:[728,90]
          },
          mobile:{
              dimensions:[320,50]
          }
      }
    }
    @ad_slots[:City_Page] = {
        Content_Top: {
            name: "Content_Top",
            desktop:{
                dimensions:[300,250]
            }
        },
        Text: {
            name: "Text",
            desktop:{
                dimensions:[[728,60],[728,90]]
            },
            mobile:{
                dimensions:[[320,60],[320,50]]
            }
        },
        Footer: {
            name: "Footer",
            desktop:{
                dimensions:[728,90]
            },
            mobile:{
                dimensions:[320,50]
            }
        },
    }

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