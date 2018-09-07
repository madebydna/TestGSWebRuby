
# frozen_string_literal: true

module AdvertisingAndPageAnalyticsConcerns
  include AdvertisingConcerns 
  include PageAnalytics

  def compfilter
    @_comfilter ||= rand(1..4).to_s
  end

end