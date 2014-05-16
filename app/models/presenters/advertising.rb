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
      Test_Scores: {
        name: "Test_Scores",
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
    @ad_slots[:Quality] = {
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

      @ad_slots[page][slot][view].nil? ? @ad_slots[page][slot][:desktop][:width] : @ad_slots[page][slot][view][:width]
    end

    def get_height(page, slot, view)
      @ad_slots[page][slot][view].nil? ? @ad_slots[page][slot][:desktop][:height] : @ad_slots[page][slot][view][:height]
    end

  end
end