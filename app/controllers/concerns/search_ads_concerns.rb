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
            {name:'Content_Top'}
        ],
        mobile: [
            {name:'Content_Top'},
        ]
    }
  end

  def footer_ad_slots
    {
        desktop: [
            {name:'Footer'}
        ],
        mobile: [
            {name:'Footer'}
        ]
    }
  end

  def results_ad_slots
    {
        desktop: [
            {name:'After4'},
            {name:'After8_Text'},
            [
                {name:'After12_Left'},
                {name:'After12_Right'}
            ],
            {name:'After16'},
            {name:'After20'}
        ],
        mobile: [
            {name:'After4'},
            {name:'After8_Text'},
            {name:'After12'},
            {name:'After16'},
            {name:'After20'}
        ]
    }
  end
end