module Newsletter
  class DistrictGradeByGrade
    attr_accessor :district_route

    def initialize(district_route)
      @district_route = district_route
    end

    def district
      params = district_partner_routes[district_route]
      return nil unless params.present?

      DistrictRecord.find_by(state: params[:state], district_id: params[:district_id])
    end

    def logo
      district_logos[district_route]
    end

    private

    def district_partner_routes
      {
        'susd' => {state: 'ca', district_id: 759},
        'cabrillo' => {state: 'ca', district_id: 783}
      }
    end

    def district_logos
      {
        'susd' => 'district_logos/susd-logo.png',
        'cabrillo' => 'district_logos/cabrillo-logo.png'
      }
    end
  end
end