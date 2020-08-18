module Api
  # This class organizes the credit card details for the front end
  class CreditCardDetails

    attr_reader :card_details, :billing_details

    def self.call(card_details, billing_details)
      new(card_details, billing_details)
    end

    def initialize(card_details, billing_details)
      @card_details = card_details
      @billing_details = billing_details
    end

    def last_four
      card_details[:last4]
    end

    def brand
      card_details[:brand]
    end

    def name
      billing_details[:name]
    end

    def address
      [billing_details[:address][:line1], billing_details[:address][:line2]].compact.join(' ')&.strip
    end

    def locality
      [city, state].join(', ')
    end

    def zipcode
      billing_details[:address][:postal_code]
    end

    private

    def city
      billing_details[:address][:city].split(' ').map(&:capitalize).join(' ')
    end

    def state
      billing_details[:address][:state]&.upcase
    end

  end

end