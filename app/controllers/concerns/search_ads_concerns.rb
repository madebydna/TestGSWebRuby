module SearchAdsConcerns
  extend ActiveSupport::Concern

  protected

  def set_search_ad_slots_instance_variables
    @header_ad_slots = header_ad_slots
    @footer_ad_slots = footer_ad_slots
    @results_ad_slots = results_ad_slots
  end

  def header_ad_slots
    {
        desktop: [
            {name:'Responsive_Search_Results1_728x90',  dimensions: [728, 90]},
        ],
        mobile: [
            {name:'Responsive_Mobile_Search_Results1_320x50',  dimensions: [320, 50]},
        ]
    }
  end

  def footer_ad_slots
    {
        desktop: [
            {name:'Responsive_Search_Results5_728x90',  dimensions: [728, 90]}
        ],
        mobile: [
            {name:'Responsive_Mobile_Search_Results4_320x50',  dimensions: [320, 50]}
        ]
    }
  end

  def results_ad_slots
    {
        desktop: [
            {name:'Responsive_Search_Results2_728x90', dimensions: [728, 90]},
            {name:'Responsive_Search_Results_Text_728x60',  dimensions: [728, 60]},
            [
                {name:'Responsive_Search_Results1_300x250',  dimensions: [300, 250]},
                {name:'Responsive_Search_Results2_300x250',  dimensions: [300, 250]}
            ],
            {name:'Responsive_Search_Results3_728x90',  dimensions: [728, 90]},
            {name:'Responsive_Search_Results4_728x90',  dimensions: [728, 90]}
        ],
        mobile: [
            {name:'Responsive_Mobile_Search_Results1_300x250', dimensions: [300, 250]},
            {name:'Responsive_Mobile_Search_Results_Text_320x60',  dimensions: [320, 60]},
            {name:'Responsive_Mobile_Search_Results2_320x50',  dimensions: [320, 50]},
            {name:'Responsive_Mobile_Search_Results2_300x250',  dimensions: [320, 250]},
            {name:'Responsive_Mobile_Search_Results3_320x50',  dimensions: [320, 50]}
        ]
    }
  end
end